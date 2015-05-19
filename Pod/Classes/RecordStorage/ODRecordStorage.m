//
//  ODRecordStorage.m
//  Pods
//
//  Created by atwork on 4/5/15.
//
//

#import "ODRecordStorage.h"
#import "ODRecordChange_Private.h"
#import "ODRecordStorageMemoryStore.h"
#import "ODRecordStorageFileBackedMemoryStore.h"
#import "ODRecordSynchronizer.h"

@interface ODRecordStorage ()

- (void)shouldProcessChanges;

@end

@implementation ODRecordStorage {
    NSMapTable *_records;
    NSMutableDictionary *_recordsPendingSave;
    NSMutableDictionary *_recordsPendingDelete;
    ODRecordResolveMethod _defaultResolveMethod;
    
    NSMutableArray *_pendingChanges;
    NSMutableArray *_failedChanges;
    NSMutableDictionary *_completionBlocks;
}

- (instancetype)initWithBackingStore:(id<ODRecordStorageBackingStore>)backingStore
{
    self = [super init];
    if (self) {
        _records = [NSMapTable strongToWeakObjectsMapTable];
        _backingStore = backingStore;
        _defaultResolveMethod = ODRecordResolveByReplacing;
        _pendingChanges = [[NSMutableArray alloc] init];
        _failedChanges = [[NSMutableArray alloc] init];
        _recordsPendingSave = [[NSMutableDictionary alloc] init];
        _recordsPendingDelete = [[NSMutableDictionary alloc] init];
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

#pragma mark - Fetch, save and delete records

- (ODRecord *)_getCacheRecordWithRecordID:(ODRecordID *)recordID
{
    ODRecord *record = [_records objectForKey:recordID];
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
    // Query the backing store for record IDs of the specified type.
    NSArray *recordIDs = [_backingStore queryRecordIDsWithRecordType:recordType];
    
    // Fetch each record, the record may come from the cache or the backing store. Ignore records that are pending delete.
    NSMutableArray *records = [NSMutableArray array];
    [recordIDs enumerateObjectsUsingBlock:^(ODRecordID *recordID, NSUInteger idx, BOOL *stop) {
        if (![_recordsPendingDelete objectForKey:recordID]) {
            [records addObject:[self recordWithRecordID:recordID]];
        }
    }];
    
    // Include records that are pending save to the output array.
    [_recordsPendingSave enumerateKeysAndObjectsUsingBlock:^(ODRecordID *recordID,
                                                            ODRecord *record, BOOL *stop) {
        if ([recordID.recordType isEqualToString:recordType]
            && ![recordIDs containsObject:recordID])
        {
            [records addObject:[self recordWithRecordID:recordID]];
        }
    }];
    
// FIXME: ODRecord is not key value coding compliant
//    if (predicate) {
//        [records filterUsingPredicate:predicate];
//    }
//    if ([sortDescriptors count]) {
//        [records sortUsingDescriptors:sortDescriptors];
//    }
    return records;
}

- (void)enumerateRecordsWithType:(NSString *)recordType predicate:(NSPredicate *)predicate sortDescriptors:(NSArray *)sortDescriptors usingBlock:(void (^)(ODRecord *, BOOL *))block
{
    if (block) {
        // FIXME: inefficient implementation
        NSArray *records = [self recordsWithType:recordType predicate:predicate sortDescriptors:sortDescriptors];
        [records enumerateObjectsUsingBlock:^(ODRecord *obj, NSUInteger idx, BOOL *stop) {
            NSAssert([obj isKindOfClass:[ODRecord class]],
                     @"%@ is expected to be an ODRecord.", NSStringFromClass([obj class]));
            block(obj, stop);
        }];
    }
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
        [_synchronizer recordStorage:self
                         saveChanges:[self.pendingChanges copy]];
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

- (NSArray *)pendingChanges
{
    return [_pendingChanges copy];
}

- (NSArray *)failedChanges
{
    return [_failedChanges copy];
}

- (ODRecordChange *)changeWithRecord:(ODRecord *)record
{
    // FIXME: inefficient implementation
    __block ODRecordChange *change = nil;
    ODRecordID *wantedID = record.recordID;
    void (^enumerateBlock)(id, NSUInteger, BOOL *) = ^(ODRecordChange *obj, NSUInteger idx, BOOL *stop) {
        NSAssert([obj isKindOfClass:[ODRecordChange class]],
                 @"%@ is expected to be an ODRecordChange.", NSStringFromClass([obj class]));
        if ([obj.recordID isEqual:wantedID]) {
            change = obj;
            *stop = YES;
        }
    };
    
    for (NSArray *changesArray in @[_pendingChanges, _failedChanges]) {
        [changesArray enumerateObjectsUsingBlock:enumerateBlock];
        if (change) {
            return change;
        }
    }
    return nil;
}

- (void)_appendChange:(ODRecordChange *)change record:(ODRecord *)record completion:(id)handler
{
    [self _dismissExistingChangeIfAnyWithRecord:record error:nil];
    change.state = ODRecordChangeStateWaiting;
    [_pendingChanges addObject:change];
    
    switch (change.action) {
        case ODRecordChangeSave:
            [_recordsPendingSave setObject:record forKey:record.recordID];
            break;
        case ODRecordChangeDelete:
            [_recordsPendingDelete setObject:record forKey:record.recordID];
            break;
    }
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
        [_failedChanges removeObject:item];
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
        [_pendingChanges removeObject:item];
        switch(item.action) {
            case ODRecordChangeSave:
                [_recordsPendingSave removeObjectForKey:item.recordID];
                break;
            case ODRecordChangeDelete:
                [_recordsPendingDelete removeObjectForKey:item.recordID];
                break;
        }
        [_completionBlocks removeObjectForKey:item.recordID];
        return YES;
    }
}

- (void)dismissFailedChangesWithBlock:(BOOL (^)(ODRecordChange *, ODRecord *))block
{
    if (block) {
        NSArray *failedChangesCopy = [_failedChanges copy];
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
    [_backingStore enumerateRecordsWithBlock:^(ODRecord *record) {
        [oldRecordIDs addObject:record.recordID];
    }];
    
    [records enumerateObjectsUsingBlock:^(ODRecord *obj, NSUInteger idx, BOOL *stop) {
        if ([oldRecordIDs containsObject:obj.recordID]) {
            [_backingStore updateRecord:obj];
            [oldRecordIDs removeObject:obj.recordID];
        } else {
            [_backingStore insertRecord:obj];
        }
    }];
    
    [oldRecordIDs enumerateObjectsUsingBlock:^(ODRecordID *obj, NSUInteger idx, BOOL *stop) {
        [_backingStore deleteRecordWithRecordID:obj];
    }];
}

- (void)updateByApplyingChange:(ODRecordChange *)change
                     recordOnRemote:(ODRecord *)remoteRecord
                              error:(NSError *)error
{
    [_pendingChanges removeObject:change];
    if (error) {
        change.error = error;
        [_failedChanges addObject:change];
    } else {
        if (change.action == ODRecordChangeSave) {
            if ([_backingStore existsRecordWithRecordID:change.recordID]) {
                [_backingStore updateRecord:remoteRecord];
            } else {
                [_backingStore insertRecord:remoteRecord];
            }
            [_recordsPendingSave removeObjectForKey:change.recordID];
        } else if (change.action == ODRecordChangeDelete) {
            ODRecord *recordToDelete = [_backingStore fetchRecordWithRecordID:change.recordID];
            [_backingStore deleteRecord:recordToDelete];
            [_recordsPendingDelete removeObjectForKey:change.recordID];
        }
        void (^block)() = [_completionBlocks objectForKey:change.recordID];
        if (block) {
            block();
        }
    }
    change.state = ODRecordChangeStateFinished;
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
    
    // FIXME need to post notification
}

@end
