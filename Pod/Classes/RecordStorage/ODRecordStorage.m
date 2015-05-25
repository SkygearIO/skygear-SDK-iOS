//
//  ODRecordStorage.m
//  Pods
//
//  Created by atwork on 4/5/15.
//
//

#import "ODRecordStorage.h"
#import "ODRecordChange.h"
#import "ODRecordStorageMemoryStore.h"
#import "ODRecordStorageFileBackedMemoryStore.h"
#import "ODRecordSynchronizer.h"

NSString * const ODRecordStorageDidUpdateNotification = @"ODRecordStorageDidUpdateNotification";

@interface ODRecordStorage ()

- (void)shouldProcessChanges;

@end

@implementation ODRecordStorage {
    NSMapTable *_records;
    ODRecordResolveMethod _defaultResolveMethod;
    NSMutableDictionary *_completionBlocks;
}

- (instancetype)initWithBackingStore:(id<ODRecordStorageBackingStore>)backingStore
{
    self = [super init];
    if (self) {
        _records = [NSMapTable strongToWeakObjectsMapTable];
        _backingStore = backingStore;
        _defaultResolveMethod = ODRecordResolveByReplacing;
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

#pragma mark - Changing all records with force

- (BOOL)performUpdateWithError:(NSError **)error
{
    if (self.hasPendingChanges) {
        if (error) {
            NSDictionary *userInfo = @{
                                      NSLocalizedDescriptionKey: @"Unable to perform update because"
                                      @" there are pending changes."
                                      };
            *error = [NSError errorWithDomain:@"ODRecordStorageErrorDomain"
                                         code:0
                                     userInfo:userInfo];
        }
        return NO;
    }
    
    [self.synchronizer recordStorageFetchUpdates:self];
    if (error) {
        *error = nil;
    }
    return YES;
}

#pragma mark - Fetch, save and delete records

- (ODRecord *)_getCacheRecordWithRecordID:(ODRecordID *)recordID
{
    ODRecord *record = [_records objectForKey:recordID];
    return record;
}

- (ODRecord *)_getCacheRecordWithRecordID:(ODRecordID *)recordID
                         orSetCacheRecord:(ODRecord *)record
{
    ODRecord *cachedRecord = [_records objectForKey:recordID];
    if (!cachedRecord) {
        [self _setCacheRecord:record recordID:recordID];
        cachedRecord = record;
    }
    return record;
}

- (void)_setCacheRecord:(ODRecord *)record recordID:(ODRecordID *)recordID
{
    if (record) {
        [_records setObject:record forKey:recordID];
    } else {
        [_records removeObjectForKey:recordID];
    }
}

- (ODRecord *)recordWithRecordID:(ODRecordID *)recordID
{
    ODRecord *record = [self _getCacheRecordWithRecordID:recordID];
    if (![record isKindOfClass:[ODRecord class]]) {
        record = [_backingStore fetchRecordWithRecordID:recordID];
        [self _setCacheRecord:record recordID:recordID];
    }
    return record;
}

- (void)saveRecord:(ODRecord *)record
{
    [self saveRecord:record whenConflict:_defaultResolveMethod completionHandler:nil];
}

- (void)saveRecord:(ODRecord *)record whenConflict:(ODRecordResolveMethod)resolution completionHandler:(id)handler
{
    NSDictionary *attributesToSave = [self attributesToSaveWithRecord:record];
    ODRecordChange *change = [[ODRecordChange alloc] initWithRecord:record
                                                             action:ODRecordChangeSave
                                                      resolveMethod:resolution
                                                   attributesToSave:attributesToSave];
    
    [self _setCacheRecord:record recordID:record.recordID];
    [self _appendChange:change record:record completion:handler];
}

- (void)saveRecords:(NSArray *)records
{
    [records enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [self saveRecord:(ODRecord *)obj whenConflict:_defaultResolveMethod completionHandler:nil];
    }];
}

- (void)deleteRecord:(ODRecord *)record
{
    [self deleteRecord:record whenConflict:_defaultResolveMethod completionHandler:nil];
}

- (void)deleteRecord:(ODRecord *)record whenConflict:(ODRecordResolveMethod)resolution completionHandler:(id)handler
{
    ODRecordChange *change = [[ODRecordChange alloc] initWithRecord:record
                                                             action:ODRecordChangeDelete
                                                      resolveMethod:resolution
                                                   attributesToSave:nil];

    [self _setCacheRecord:nil recordID:record.recordID];
    [self _appendChange:change record:record completion:handler];
}

- (void)deleteRecords:(NSArray *)records
{
    [records enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [self deleteRecord:(ODRecord *)obj whenConflict:_defaultResolveMethod completionHandler:nil];
    }];
}

- (ODRecordState)recordStateWithRecord:(ODRecord *)record
{
    ODRecordChange *change = [self changeWithRecord:record];
    if (change && change.error) {
        return ODRecordStateConflicted;
    } else if (change) {
        return ODRecordStateSynchronizing;
    } else {
        return ODRecordStateSynchronized;
    }
}

#pragma mark - Query

- (NSArray *)recordsWithType:(NSString *)recordType
{
    return [self recordsWithType:recordType predicate:nil sortDescriptors:nil];
}

- (NSArray *)recordsWithType:(NSString *)recordType predicate:(NSPredicate *)predicate sortDescriptors:(NSArray *)sortDescriptors
{
    NSMutableArray *records = [[NSMutableArray alloc] init];
    [self enumerateRecordsWithType:recordType
                         predicate:predicate
                   sortDescriptors:sortDescriptors
                        usingBlock:^(ODRecord *record, BOOL *stop) {
                            [records addObject:record];
                        }];
    
    NSLog(@"%@: Query for record type `%@` returns %lu records. Predicate: %@",
          self, recordType, [records count], predicate);

    return records;
}

- (void)enumerateRecordsWithType:(NSString *)recordType predicate:(NSPredicate *)predicate sortDescriptors:(NSArray *)sortDescriptors usingBlock:(void (^)(ODRecord *, BOOL *))block
{
    if (!block) {
        return;
    }
    
    [_backingStore enumerateRecordsWithType:recordType
                                  predicate:predicate
                            sortDescriptors:sortDescriptors
                                 usingBlock:^(ODRecord *record, BOOL *stop) {
                                     ODRecord *result =
                                         [self _getCacheRecordWithRecordID:record.recordID
                                                          orSetCacheRecord:record];
                                     block(result, stop);
                                 }];
}

#pragma mark - Change processing

- (void)shouldFetchUpdates
{
    if (self.enabled) {
        [_synchronizer recordStorageFetchUpdates:self];
    }
}

- (void)shouldProcessChanges
{
    if (self.enabled) {
        if (self.hasPendingChanges) {
            NSLog(@"%@: Enabled and detected %lu pending changes."
                  " Will ask synchronizer to save changes.",
                  self, [_backingStore pendingChangesCount]);
            [_synchronizer recordStorage:self
                             saveChanges:self.pendingChanges];
        } else {
            NSLog(@"%@: Enabled but there are no no pending changes.", self);
        }
    }
}

#pragma mark - Change management

- (NSDictionary *)attributesToSaveWithRecord:(ODRecord *)record
{
    ODRecord *oldRecord = [_backingStore fetchRecordWithRecordID:record.recordID];
    NSDictionary *oldDictionary = [oldRecord dictionary];
    NSMutableDictionary *difference = [NSMutableDictionary dictionary];
    [record.dictionary enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        id oldValue = [oldDictionary objectForKey:key];
        if (![oldValue isEqual:obj]) {
            difference[key] = @[oldValue ? oldValue : [NSNull null],
                                obj ? obj : [NSNull null]];
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

- (ODRecordChange *)changeWithRecord:(ODRecord *)record
{
    return [_backingStore changeWithRecordID:record.recordID];
}

- (void)_appendChange:(ODRecordChange *)change record:(ODRecord *)record completion:(id)handler
{
    [self _dismissExistingChangeIfAnyWithRecord:record error:nil];
    [_backingStore appendChange:change state:ODRecordChangeStateWaiting];
    switch (change.action) {
        case ODRecordChangeSave:
            [_backingStore saveRecordLocally:record];
            break;
        case ODRecordChangeDelete:
            [_backingStore deleteRecordLocally:record];
            break;
    }
    [_backingStore synchronize];
    if (handler) {
        [_completionBlocks setObject:[handler copy] forKey:change.recordID];
    }
    [self shouldProcessChanges];
}
        
- (BOOL)_dismissExistingChangeIfAnyWithRecord:(ODRecord *)record error:(NSError **)error
{
    BOOL success;
    ODRecordChange *existingChange = [self changeWithRecord:record];
    if (existingChange) {
        success = [self dismissChange:existingChange error:error];
    } else {
        success = YES;
    }
    NSAssert(success, @"error handling not implemented");
    return success;
}

- (BOOL)dismissChange:(ODRecordChange *)item error:(NSError *__autoreleasing *)error
{
    if (item.error) {
        [_backingStore removeChange:item];
        [_backingStore revertRecordLocallyWithRecordID:item.recordID];
        [_backingStore synchronize];
        [_completionBlocks removeObjectForKey:item.recordID];
        return YES;
    } else {
        if (item.state == ODRecordChangeStateStarted) {
            if (error) {
                *error = [NSError errorWithDomain:@"ODRecordStorageErrorDomain"
                                             code:0
                                         userInfo:@{
                                                    NSLocalizedDescriptionKey: @"Cannot dismiss a started change."
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

- (void)dismissFailedChangesWithBlock:(BOOL (^)(ODRecordChange *, ODRecord *))block
{
    if (block) {
        NSArray *failedChangesCopy = [_backingStore failedChanges];
        [failedChangesCopy enumerateObjectsUsingBlock:^(ODRecordChange *obj, NSUInteger idx, BOOL *stop) {
            NSAssert([obj isKindOfClass:[ODRecordChange class]],
                     @"%@ is expected to be an ODRecordChange.", NSStringFromClass([obj class]));
            ODRecord *record = [self recordWithRecordID:obj.recordID];
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
    [_backingStore enumerateRecordsWithBlock:^(ODRecord *record, BOOL *stop) {
        [oldRecordIDs addObject:record.recordID];
    }];
    
    [records enumerateObjectsUsingBlock:^(ODRecord *obj, NSUInteger idx, BOOL *stop) {
        [_backingStore saveRecord:obj];
        [_records setObject:obj forKey:obj.recordID];
        [oldRecordIDs removeObject:obj.recordID];
    }];
    
    [oldRecordIDs enumerateObjectsUsingBlock:^(ODRecordID *obj, NSUInteger idx, BOOL *stop) {
        [_backingStore deleteRecordWithRecordID:obj];
        [_records removeObjectForKey:obj];
    }];
}

- (void)updateByApplyingChange:(ODRecordChange *)change
                     recordOnRemote:(ODRecord *)remoteRecord
                              error:(NSError *)error
{
    if (error) {
        [_backingStore setFinishedStateWithError:error ofChange:change];
    } else {
        if (change.action == ODRecordChangeSave) {
            [_backingStore saveRecord:remoteRecord];
        } else if (change.action == ODRecordChangeDelete) {
            ODRecord *recordToDelete = [_backingStore fetchRecordWithRecordID:change.recordID];
            if (recordToDelete) {
                [_backingStore deleteRecord:recordToDelete];
            }
        }
        void (^block)() = [_completionBlocks objectForKey:change.recordID];
        if (block) {
            block();
        }
        [_backingStore setState:ODRecordChangeStateFinished ofChange:change];
    }
}

- (void)beginUpdating
{
    NSAssert(!_updating, @"Calling %@ while updating is not defined.", NSStringFromSelector(_cmd));
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
    
    [[NSNotificationCenter defaultCenter] postNotificationName:ODRecordStorageDidUpdateNotification
                                                        object:self
                                                      userInfo:nil];
}

@end
