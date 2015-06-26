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
        [self purgeWithError:nil];
    }
    return self;
}

- (BOOL)purgeWithError:(NSError **)error
{
    _records = [[NSMutableDictionary alloc] init];
    _changes = [[NSMutableArray alloc] init];
    _localRecords = [[NSMutableDictionary alloc] init];
    return YES;
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

- (NSArray *)recordIDsWithRecordType:(NSString *)recordType
{
    NSMutableArray *wantedRecordIDs = [[NSMutableArray alloc] init];
    [self enumerateRecordsWithBlock:^(ODRecord *record, BOOL *stop) {
        if ([record.recordID.recordType isEqualToString:recordType]) {
            [wantedRecordIDs addObject:record.recordID];
        }
    }];
    return wantedRecordIDs;
}

- (void)enumerateRecordsWithBlock:(void (^)(ODRecord *, BOOL *))block
{
    if (!block) {
        return;
    }
    
    [_records enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        if ([_localRecords objectForKey:key]) {
            return;
        }
        block([obj copy], stop);
    }];
    [_localRecords enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        if ([[NSNull null] isEqual:obj]) {
            return;
        }
        block([obj copy], stop);
    }];
}

- (void)enumerateRecordsWithType:(NSString *)recordType
                       predicate:(NSPredicate *)predicate
                 sortDescriptors:(NSArray *)sortDescriptors
                      usingBlock:(void (^)(ODRecord *, BOOL *))block
{
    if (!block) {
        return;
    }
    
    NSMutableArray *result = [[NSMutableArray alloc] init];
    [self enumerateRecordsWithBlock:^(ODRecord *record, BOOL *stop) {
        if ([recordType isEqualToString:record.recordType] && (!predicate || [predicate evaluateWithObject:record])) {
            if ([sortDescriptors count]) {
                [result addObject:record];
            } else {
                block(record, stop);
            }
        }
    }];
    
    if ([sortDescriptors count]) {
        [result sortUsingDescriptors:sortDescriptors];
        [result enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            block(obj, stop);
        }];
    }
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

- (void)removeChange:(ODRecordChange *)change
{
    [_changes removeObject:change];
    [self synchronize];
}

- (void)setFinishedWithError:(NSError *)error change:(ODRecordChange *)change
{
    change.finished = YES;
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

- (NSUInteger)pendingChangesCount
{
    return [[self pendingChanges] count];
}

- (NSArray *)pendingChanges
{
    return [_changes filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"finished = NO"]];
}

- (NSArray *)failedChanges
{
    return [_changes filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"finished = YES AND error != NULL"]];
}

@end
