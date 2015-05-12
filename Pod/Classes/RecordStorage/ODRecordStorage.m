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

@interface ODRecordStorage ()

- (void)shouldProcessChanges;

@end

@implementation ODRecordStorage {
    id<ODRecordStorageBackingStore> _backingStore;
    NSMapTable *_records;
    ODRecordResolveMethod _defaultResolveMethod;
    
    NSMutableArray *_pendingChanges;
    NSMutableArray *_failedChanges;
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
    [self _appendChange:change];
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
    [self _appendChange:change];
}

- (void)deleteRecords:(NSArray *)records
{
    [records enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [self deleteRecord:(ODRecord *)obj whenConflict:_defaultResolveMethod completionHandler:nil];
    }];
}

#pragma mark - Query

- (NSArray *)recordsWithType:(NSString *)recordType
{
    return [self recordsWithType:recordType predicate:nil sortDescriptors:nil];
}

- (NSArray *)recordsWithType:(NSString *)recordType predicate:(NSPredicate *)predicate sortDescriptors:(NSArray *)sortDescriptors
{
    NSArray *recordIDs = [_backingStore queryRecordIDsWithRecordType:recordType];
    NSMutableArray *records = [NSMutableArray array];
    [recordIDs enumerateObjectsUsingBlock:^(ODRecordID *obj, NSUInteger idx, BOOL *stop) {
        [records addObject:[self recordWithRecordID:obj]];
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

- (void)shouldProcessChanges
{
    if (self.enabled) {
        // FIXME: The while loop assumes that pending changes are processed
        // sequentially and the first one is always dequeued at every iteration.
        // This assumption may not be true with network requests.
        while ([_pendingChanges count] > 0) {
            ODRecordChange *oneChange = [_pendingChanges objectAtIndex:0];
            [self processChange:oneChange];
            [_pendingChanges removeObject:oneChange];
        }
        [_backingStore synchronize];
    }
}

- (void)processChange:(ODRecordChange *)change
{
    if (change.action == ODRecordChangeSave) {
        ODRecord *recordToSave = [_backingStore fetchRecordWithRecordID:change.recordID];
        if (recordToSave) {
            [change.attributesToSave enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
                recordToSave[key] = obj;
            }];
            [_backingStore updateRecord:recordToSave];
        } else {
            NSMutableDictionary *attributes = [NSMutableDictionary dictionary];
            [change.attributesToSave enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
                attributes[key] = obj[1];
            }];
            recordToSave = [[ODRecord alloc] initWithRecordID:change.recordID data:attributes];
            [_backingStore insertRecord:recordToSave];
        }
    } else if (change.action == ODRecordChangeDelete) {
        ODRecord *recordToDelete = [_backingStore fetchRecordWithRecordID:change.recordID];
        [_backingStore deleteRecord:recordToDelete];
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

- (void)_appendChange:(ODRecordChange *)change
{
    [_pendingChanges addObject:change];
    [self shouldProcessChanges];
}

- (BOOL)dismissChange:(ODRecordChange *)item error:(NSError *__autoreleasing *)error
{
    if (item.error) {
        [_failedChanges removeObject:item];
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

@end
