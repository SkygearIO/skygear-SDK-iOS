//
//  SKYRecordStorage.m
//  SKYKit
//
//  Copyright 2015 Oursky Ltd.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

#import "SKYRecordStorage.h"
#import "SKYContainer.h"
#import "SKYRecordChange.h"
#import "SKYRecordStorageFileBackedMemoryStore.h"
#import "SKYRecordStorageMemoryStore.h"
#import "SKYRecordStorage_Private.h"
#import "SKYRecordSynchronizer.h"
#import "SKYRecord_Private.h"

NSString *const SKYRecordStorageDidUpdateNotification = @"SKYRecordStorageDidUpdateNotification";
NSString *const SKYRecordStorageWillSynchronizeChangesNotification =
    @"SKYRecordStorageWillSynchronizeChangesNotification";
NSString *const SKYRecordStorageDidSynchronizeChangesNotification =
    @"SKYRecordStorageDidSynchronizeChangesNotification";
NSString *const SKYRecordStorageUpdateAvailableNotification =
    @"SKYRecordStorageUpdateAvailableNotification";
NSString *const SKYRecordStoragePendingChangesCountKey = @"pendingChangesCount";
NSString *const SKYRecordStorageFailedChangesCountKey = @"failedChangesCount";
NSString *const SKYRecordStorageSavedRecordIDsKey = @"savedRecordIDs";
NSString *const SKYRecordStorageDeletedRecordIDsKey = @"deletedRecordIDs";

@interface SKYRecordStorage ()

- (void)shouldProcessChanges;

@end

@implementation SKYRecordStorage {
    NSMapTable *_records;
    SKYRecordResolveMethod _defaultResolveMethod;
    NSMutableDictionary *_completionBlocks;
    BOOL _updatingForChanges;
    NSMutableArray *_savedRecordIDs;
    NSMutableArray *_deletedRecordIDs;
}

- (instancetype)initWithBackingStore:(id<SKYRecordStorageBackingStore>)backingStore
{
    self = [super init];
    if (self) {
        _records = [NSMapTable strongToWeakObjectsMapTable];
        _backingStore = backingStore;
        _defaultResolveMethod = SKYRecordResolveByReplacing;
        _completionBlocks = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void)setEnabled:(BOOL)enabled
{
    if (_enabled != enabled) {
        [self willChangeValueForKey:@"enabled"];
        _enabled = enabled;
        [self didChangeValueForKey:@"enabled"];

        if (_enabled) {
            [self shouldFetchUpdates];
            [self shouldProcessChanges];
        }
    }
}

- (void)markAsUpdateAvailable
{
    [self willChangeValueForKey:@"hasUpdateAvailable"];
    _hasUpdateAvailable = YES;
    [self didChangeValueForKey:@"hasUpdateAvailable"];
    NSNotificationCenter *noteCenter = [NSNotificationCenter defaultCenter];
    [noteCenter postNotificationName:SKYRecordStorageUpdateAvailableNotification
                              object:self
                            userInfo:nil];
}

#pragma mark - Changing all records with force

- (void)performUpdateWithCompletionHandler:(void (^)(BOOL finished,
                                                     NSError *error))completionHandler
{
    void (^mainThreadCompletion)(BOOL finished, NSError *error) = ^(BOOL finished, NSError *error) {
        if (completionHandler) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completionHandler(finished, error);
            });
        }
    };

    if (self.hasPendingChanges) {
        [self.synchronizer recordStorage:self
                             saveChanges:[self pendingChanges]
                       completionHandler:^(BOOL finished, NSError *error) {
                           if (finished) {
                               [self.synchronizer recordStorageFetchUpdates:self
                                                          completionHandler:mainThreadCompletion];
                           } else {
                               mainThreadCompletion(NO, error);
                           }
                       }];
    } else {
        [self.synchronizer recordStorageFetchUpdates:self completionHandler:mainThreadCompletion];
    }
}

#pragma mark - Fetch, save and delete records

- (SKYRecord *)_getCacheRecordWithRecordID:(SKYRecordID *)recordID
{
    SKYRecord *record = [_records objectForKey:recordID];
    return record;
}

- (SKYRecord *)_getCacheRecordWithRecordID:(SKYRecordID *)recordID
                          orSetCacheRecord:(SKYRecord *)record
{
    SKYRecord *cachedRecord = [_records objectForKey:recordID];
    if (!cachedRecord) {
        [self _setCacheRecord:record recordID:recordID];
        cachedRecord = record;
    }
    return record;
}

- (void)_setCacheRecord:(SKYRecord *)record recordID:(SKYRecordID *)recordID
{
    if (record) {
        [_records setObject:record forKey:recordID];
    } else {
        [_records removeObjectForKey:recordID];
    }
}

- (SKYRecord *)recordWithRecordID:(SKYRecordID *)recordID
{
    SKYRecord *record = [self _getCacheRecordWithRecordID:recordID];
    if (![record isKindOfClass:[SKYRecord class]]) {
        record = [_backingStore fetchRecordWithRecordID:recordID];
        [self _setCacheRecord:record recordID:recordID];
    }
    return record;
}

- (void)saveRecord:(SKYRecord *)record
{
    [self saveRecord:record whenConflict:_defaultResolveMethod completionHandler:nil];
}

- (void)saveRecord:(SKYRecord *)record
         whenConflict:(SKYRecordResolveMethod)resolution
    completionHandler:(id)handler
{
    NSDictionary *attributesToSave = [self attributesToSaveWithRecord:record];
    SKYRecordChange *change = [[SKYRecordChange alloc] initWithRecord:record
                                                               action:SKYRecordChangeSave
                                                        resolveMethod:resolution
                                                     attributesToSave:attributesToSave];

    // Simulate changes to record metadata that will happen on the server-side.
    [record setModificationDate:[NSDate date]];
    [record setLastModifiedUserRecordID:[[SKYContainer defaultContainer] currentUserRecordID]];
    if ([record creationDate] == nil) {
        [record setCreationDate:record.modificationDate];
    }
    if ([record creatorUserRecordID] == nil) {
        [record setCreatorUserRecordID:record.lastModifiedUserRecordID];
    }
    if ([record ownerUserRecordID] == nil) {
        [record setOwnerUserRecordID:record.lastModifiedUserRecordID];
    }

    [self _setCacheRecord:record recordID:record.recordID];
    [self _appendChange:change record:record completion:handler];
}

- (void)saveRecords:(NSArray *)records
{
    [records enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [self saveRecord:(SKYRecord *)obj whenConflict:_defaultResolveMethod completionHandler:nil];
    }];
}

- (void)deleteRecord:(SKYRecord *)record
{
    [self deleteRecord:record whenConflict:_defaultResolveMethod completionHandler:nil];
}

- (void)deleteRecord:(SKYRecord *)record
         whenConflict:(SKYRecordResolveMethod)resolution
    completionHandler:(id)handler
{
    SKYRecordChange *change = [[SKYRecordChange alloc] initWithRecord:record
                                                               action:SKYRecordChangeDelete
                                                        resolveMethod:resolution
                                                     attributesToSave:nil];

    [self _setCacheRecord:nil recordID:record.recordID];
    [self _appendChange:change record:record completion:handler];
}

- (void)deleteRecords:(NSArray *)records
{
    [records enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [self deleteRecord:(SKYRecord *)obj
                 whenConflict:_defaultResolveMethod
            completionHandler:nil];
    }];
}

- (SKYRecordState)recordStateWithRecord:(SKYRecord *)record
{
    SKYRecordChange *change = [self changeWithRecord:record];
    if (change) {
        if (change.error) {
            return SKYRecordStateConflicted;
        } else if ([self.synchronizer isProcessingChange:change storage:self]) {
            return SKYRecordStateSynchronizing;
        } else if (change.finished) {
            return SKYRecordStateSynchronized;
        } else {
            return SKYRecordStateNotSynchronized;
        }
    } else {
        return SKYRecordStateSynchronized;
    }
}

#pragma mark - Query

- (NSArray *)recordsWithType:(NSString *)recordType
{
    return [self recordsWithType:recordType predicate:nil sortDescriptors:nil];
}

- (NSArray *)recordsWithType:(NSString *)recordType
                   predicate:(NSPredicate *)predicate
             sortDescriptors:(NSArray *)sortDescriptors
{
    NSMutableArray *records = [[NSMutableArray alloc] init];
    [self enumerateRecordsWithType:recordType
                         predicate:predicate
                   sortDescriptors:sortDescriptors
                        usingBlock:^(SKYRecord *record, BOOL *stop) {
                            [records addObject:record];
                        }];

    NSLog(@"%@: Query for record type `%@` returns %lu records. Predicate: %@", self, recordType,
          (unsigned long)[records count], predicate);

    return records;
}

- (void)enumerateRecordsWithType:(NSString *)recordType
                       predicate:(NSPredicate *)predicate
                 sortDescriptors:(NSArray *)sortDescriptors
                      usingBlock:(void (^)(SKYRecord *, BOOL *))block
{
    if (!block) {
        return;
    }

    [_backingStore enumerateRecordsWithType:recordType
                                  predicate:predicate
                            sortDescriptors:sortDescriptors
                                 usingBlock:^(SKYRecord *record, BOOL *stop) {
                                     SKYRecord *result =
                                         [self _getCacheRecordWithRecordID:record.recordID
                                                          orSetCacheRecord:record];
                                     block(result, stop);
                                 }];
}

#pragma mark - Change processing

- (void)shouldFetchUpdates
{
    if (self.enabled) {
        [self performUpdateWithCompletionHandler:nil];
    }
}

- (void)shouldProcessChanges
{
    if (self.enabled) {
        if (self.hasPendingChanges) {
            NSLog(@"%@: Enabled and detected %lu pending changes."
                   " Will ask synchronizer to save changes.",
                  self, (unsigned long)[self.pendingChanges count]);
            [_synchronizer recordStorage:self
                             saveChanges:self.pendingChanges
                       completionHandler:nil];
        } else {
            NSLog(@"%@: Enabled but there are no no pending changes.", self);
        }
    }
}

#pragma mark - Change management

- (NSDictionary *)attributesToSaveWithRecord:(SKYRecord *)record
{
    SKYRecord *oldRecord = [_backingStore fetchRecordWithRecordID:record.recordID];
    NSDictionary *oldDictionary = [oldRecord dictionary];
    NSMutableDictionary *difference = [NSMutableDictionary dictionary];
    [record.dictionary enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        id oldValue = [oldDictionary objectForKey:key];
        if (![oldValue isEqual:obj]) {
            difference[key] = @[ oldValue ? oldValue : [NSNull null], obj ? obj : [NSNull null] ];
        }
    }];
    return difference;
}

- (BOOL)hasPendingChanges
{
    return (BOOL)[_backingStore pendingChangesCount];
}

- (NSArray *)pendingChanges
{
    return [_backingStore pendingChanges];
}

- (NSArray *)failedChanges
{
    return [_backingStore failedChanges];
}

- (SKYRecordChange *)changeWithRecord:(SKYRecord *)record
{
    return [_backingStore changeWithRecordID:record.recordID];
}

- (void)_appendChange:(SKYRecordChange *)change record:(SKYRecord *)record completion:(id)handler
{
    [self _dismissExistingChangeIfAnyWithRecord:record error:nil];
    [_backingStore appendChange:change];
    switch (change.action) {
        case SKYRecordChangeSave:
            [_backingStore saveRecordLocally:record];
            break;
        case SKYRecordChangeDelete:
            [_backingStore deleteRecordLocally:record];
            break;
    }
    [_backingStore synchronize];
    if (handler) {
        [_completionBlocks setObject:[handler copy] forKey:change.recordID];
    }
    [self shouldProcessChanges];
}

- (BOOL)_dismissExistingChangeIfAnyWithRecord:(SKYRecord *)record error:(NSError **)error
{
    BOOL success;
    SKYRecordChange *existingChange = [self changeWithRecord:record];
    if (existingChange) {
        success = [self dismissChange:existingChange error:error];
    } else {
        success = YES;
    }
    NSAssert(success, @"error handling not implemented");
    return success;
}

- (BOOL)dismissChange:(SKYRecordChange *)item error:(NSError *__autoreleasing *)error
{
    if (item.error) {
        [_backingStore removeChange:item];
        [_backingStore revertRecordLocallyWithRecordID:item.recordID];
        [_backingStore synchronize];
        [_completionBlocks removeObjectForKey:item.recordID];
        return YES;
    } else {
        if ([_synchronizer isProcessingChange:item storage:self]) {
            if (error) {
                *error = [NSError
                    errorWithDomain:@"SKYRecordStorageErrorDomain"
                               code:0
                           userInfo:@{
                               NSLocalizedDescriptionKey : @"Cannot dismiss a started change."
                           }];
                return NO;
            }
        }
        [_backingStore removeChange:item];
        [_backingStore revertRecordLocallyWithRecordID:item.recordID];
        [_backingStore synchronize];
        [_completionBlocks removeObjectForKey:item.recordID];
        return YES;
    }
}

- (void)dismissFailedChangesWithBlock:(BOOL (^)(SKYRecordChange *, SKYRecord *))block
{
    if (block) {
        NSArray *failedChangesCopy = [_backingStore failedChanges];
        [failedChangesCopy enumerateObjectsUsingBlock:^(SKYRecordChange *obj, NSUInteger idx,
                                                        BOOL *stop) {
            NSAssert([obj isKindOfClass:[SKYRecordChange class]],
                     @"%@ is expected to be an SKYRecordChange.", NSStringFromClass([obj class]));
            SKYRecord *record = [self recordWithRecordID:obj.recordID];
            BOOL willDismiss = block(obj, record);
            if (willDismiss) {
                [self dismissChange:obj error:nil];
            }
        }];
    }
}

#pragma mark - Applying updates

- (void)updateByReplacingWithRecords:(NSArray *)records
{
    NSAssert([records isKindOfClass:[NSArray class]], @"records must be array.");
    NSMutableArray *oldRecordIDs = [NSMutableArray array];
    [_backingStore enumerateRecordsWithBlock:^(SKYRecord *record, BOOL *stop) {
        [oldRecordIDs addObject:record.recordID];
    }];

    [records enumerateObjectsUsingBlock:^(SKYRecord *obj, NSUInteger idx, BOOL *stop) {
        [_backingStore saveRecord:obj];
        [_savedRecordIDs addObject:obj.recordID];
        [_records setObject:obj forKey:obj.recordID];
        [oldRecordIDs removeObject:obj.recordID];
    }];

    [oldRecordIDs enumerateObjectsUsingBlock:^(SKYRecordID *obj, NSUInteger idx, BOOL *stop) {
        [_backingStore deleteRecordWithRecordID:obj];
        [_deletedRecordIDs addObject:obj];
        [_records removeObjectForKey:obj];
    }];
}

- (void)updateByApplyingChange:(SKYRecordChange *)change
                recordOnRemote:(SKYRecord *)remoteRecord
                         error:(NSError *)error
{
    if (error) {
        [_backingStore setFinishedWithError:error change:change];
    } else {
        if (change.action == SKYRecordChangeSave) {
            [_backingStore saveRecord:remoteRecord];
            [_savedRecordIDs addObject:remoteRecord.recordID];
        } else if (change.action == SKYRecordChangeDelete) {
            SKYRecord *recordToDelete = [_backingStore fetchRecordWithRecordID:change.recordID];
            if (recordToDelete) {
                [_backingStore deleteRecord:recordToDelete];
                [_deletedRecordIDs addObject:recordToDelete.recordID];
            }
        }
        void (^block)() = [_completionBlocks objectForKey:change.recordID];
        if (block) {
            block();
        }
        [_backingStore setFinishedWithError:nil change:change];
    }
}

- (void)beginUpdating
{
    [self beginUpdatingForChanges:NO];
}

- (void)beginUpdatingForChanges:(BOOL)forChanges
{
    NSAssert(!_updating, @"Calling %@ while updating is not defined.", NSStringFromSelector(_cmd));
    _savedRecordIDs = [NSMutableArray array];
    _deletedRecordIDs = [NSMutableArray array];
    NSNotificationCenter *noteCenter = [NSNotificationCenter defaultCenter];
    if (_updatingForChanges) {
        _updatingForChanges = forChanges;
        [noteCenter postNotificationName:SKYRecordStorageWillSynchronizeChangesNotification
                                  object:self
                                userInfo:@{
                                    SKYRecordStoragePendingChangesCountKey :
                                        @([self.backingStore pendingChangesCount])
                                }];
    }
    [self willChangeValueForKey:@"updating"];
    _updating = YES;
    [self didChangeValueForKey:@"updating"];
}

- (void)finishUpdating
{
    [_backingStore synchronize];
    [self willChangeValueForKey:@"updating"];
    _updating = NO;
    [self didChangeValueForKey:@"updating"];

    NSNotificationCenter *noteCenter = [NSNotificationCenter defaultCenter];
    if (_updatingForChanges) {
        [noteCenter postNotificationName:SKYRecordStorageDidSynchronizeChangesNotification
                                  object:self
                                userInfo:@{
                                    SKYRecordStorageFailedChangesCountKey :
                                        @([[self.backingStore failedChanges] count])
                                }];
        _updatingForChanges = NO;
    }

    [noteCenter postNotificationName:SKYRecordStorageDidUpdateNotification
                              object:self
                            userInfo:@{
                                SKYRecordStorageSavedRecordIDsKey : [_savedRecordIDs copy],
                                SKYRecordStorageSavedRecordIDsKey : [_deletedRecordIDs copy],
                            }];

    _savedRecordIDs = nil;
    _deletedRecordIDs = nil;
}

@end
