//
//  ODRecordStorageMemoryStore.m
//  Pods
//
//  Created by atwork on 5/5/15.
//
//

#import "ODRecordStorageMemoryStore.h"
#import "ODRecordStorageMemoryStore_Private.h"
#import "ODRecord.h"
#import "ODRecordID.h"
#import "ODRecordChange_Private.h"

@implementation ODRecordStorageMemoryStore

- (instancetype)init
{
    self = [super init];
    if (self) {
        _records = [[NSMutableDictionary alloc] init];
        _changes = [[NSMutableArray alloc] init];
        _localRecords = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void)insertRecord:(ODRecord *)record
{
    [self saveRecord:record];
}

- (void)updateRecord:(ODRecord *)record
{
    [self saveRecord:record];
}

- (void)saveRecord:(ODRecord *)record
{
    [_records setObject:[record copy] forKey:record.recordID];
    [_localRecords removeObjectForKey:record.recordID];
}

- (void)deleteRecord:(ODRecord *)record
{
    [_records removeObjectForKey:record.recordID];
    [_localRecords removeObjectForKey:record.recordID];
}

- (void)deleteRecordWithRecordID:(ODRecordID *)recordID
{
    [_records removeObjectForKey:recordID];
    [_localRecords removeObjectForKey:recordID];
}

- (void)saveRecordLocally:(ODRecord *)record
{
    [_localRecords setObject:record forKey:record.recordID];
}

- (void)deleteRecordLocally:(ODRecord *)record
{
    [_localRecords setObject:[NSNull null] forKey:record.recordID];
}

- (void)deleteRecordLocallyWithRecordID:(ODRecordID *)recordID
{
    [_localRecords setObject:[NSNull null] forKey:recordID];
}

- (void)revertRecordLocallyWithRecordID:(ODRecordID *)recordID
{
    [_localRecords removeObjectForKey:recordID];
}

- (BOOL)existsRecordWithRecordID:(ODRecordID *)recordID
{
    return (BOOL)[self fetchRecordWithRecordID:recordID];
}

- (ODRecord *)fetchRecordWithRecordID:(ODRecordID *)recordID
{
    id obj = [_localRecords objectForKey:recordID];
    ODRecord *result;
    if (obj) {
        result = [[NSNull null] isEqual:obj] ? nil : (ODRecord *)obj;
    } else {
        result = [_records objectForKey:recordID];
    }
    return [result copy];
}

- (NSArray *)queryRecordIDsWithRecordType:(NSString *)recordType
{
    NSMutableArray *wantedRecordIDs = [[NSMutableArray alloc] init];
    [self enumerateRecordsWithBlock:^(ODRecord *record) {
        if ([record.recordID.recordType isEqualToString:recordType]) {
            [wantedRecordIDs addObject:record.recordID];
        }
    }];
    return wantedRecordIDs;
}

- (void)enumerateRecordsWithBlock:(void (^)(ODRecord *))block
{
    if (!block) {
        return;
    }
    
    [_records enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        if ([_localRecords objectForKey:key]) {
            return;
        }
        block([obj copy]);
    }];
    [_localRecords enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        if ([[NSNull null] isEqual:obj]) {
            return;
        }
        block([obj copy]);
    }];
}

- (void)synchronize
{
    // do nothing
}

#pragma mark - Changes

- (void)appendChange:(ODRecordChange *)change
{
    [_changes addObject:change];
    [self synchronize];
}

- (void)appendChange:(ODRecordChange *)change state:(ODRecordChangeState)state
{
    change.state = state;
    [_changes addObject:change];
    [self synchronize];
}

- (void)removeChange:(ODRecordChange *)change
{
    [_changes removeObject:change];
    [self synchronize];
}

- (void)setState:(ODRecordChangeState)state ofChange:(ODRecordChange *)change
{
    change.state = state;
    if (change.state == ODRecordChangeStateFinished && !change.error) {
        [_changes removeObject:change];
    }
    [self synchronize];
}

- (void)setFinishedStateWithError:(NSError *)error ofChange:(ODRecordChange *)change
{
    change.state = ODRecordChangeStateFinished;
    change.error = error;
    [self synchronize];
}

- (ODRecordChange *)changeWithRecordID:(ODRecordID *)recordID
{
    for (ODRecordChange *change in _changes) {
        if ([recordID isEqual:change.recordID]) {
            return change;
        }
    }
    return nil;
}

- (NSArray *)pendingChanges
{
    return [_changes filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"error = NULL"]];
}

- (NSArray *)failedChanges
{
    return [_changes filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"error != NULL"]];
}

- (NSArray *)recordIDsPendingSave
{
    NSMutableArray *result = [NSMutableArray array];
    for (ODRecordChange *change in [self pendingChanges]) {
        if (change.action == ODRecordChangeSave) {
            [result addObject:change.recordID];
        }
    }
    return result;
}

- (NSArray *)recordIDsPendingDelete
{
    NSMutableArray *result = [NSMutableArray array];
    for (ODRecordChange *change in [self pendingChanges]) {
        if (change.action == ODRecordChangeDelete) {
            [result addObject:change.recordID];
        }
    }
    return result;
}

@end
