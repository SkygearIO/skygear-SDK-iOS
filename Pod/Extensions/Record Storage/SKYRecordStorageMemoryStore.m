//
//  SKYRecordStorageMemoryStore.m
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

#import "SKYRecordStorageMemoryStore.h"
#import "SKYRecord.h"
#import "SKYRecordChange_Private.h"
#import "SKYRecordID.h"
#import "SKYRecordStorageMemoryStore_Private.h"

#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"
#pragma GCC diagnostic ignored "-Wdeprecated-implementations"

@implementation SKYRecordStorageMemoryStore

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

- (void)insertRecord:(SKYRecord *)record
{
    [self saveRecord:record];
}

- (void)updateRecord:(SKYRecord *)record
{
    [self saveRecord:record];
}

- (void)saveRecord:(SKYRecord *)record
{
    [_records setObject:[record copy] forKey:record.deprecatedID];
    [_localRecords removeObjectForKey:record.deprecatedID];
}

- (void)deleteRecord:(SKYRecord *)record
{
    [_records removeObjectForKey:record.deprecatedID];
    [_localRecords removeObjectForKey:record.deprecatedID];
}

- (void)deleteRecordWithRecordID:(SKYRecordID *)recordID
{
    [_records removeObjectForKey:recordID];
    [_localRecords removeObjectForKey:recordID];
}

- (void)saveRecordLocally:(SKYRecord *)record
{
    [_localRecords setObject:record forKey:record.deprecatedID];
}

- (void)deleteRecordLocally:(SKYRecord *)record
{
    [_localRecords setObject:[NSNull null] forKey:record.deprecatedID];
}

- (void)deleteRecordLocallyWithRecordID:(SKYRecordID *)recordID
{
    [_localRecords setObject:[NSNull null] forKey:recordID];
}

- (void)revertRecordLocallyWithRecordID:(SKYRecordID *)recordID
{
    [_localRecords removeObjectForKey:recordID];
}

- (BOOL)existsRecordWithRecordID:(SKYRecordID *)recordID
{
    return (BOOL)[self fetchRecordWithRecordID:recordID];
}

- (SKYRecord *)fetchRecordWithRecordID:(SKYRecordID *)recordID
{
    id obj = [_localRecords objectForKey:recordID];
    SKYRecord *result;
    if (obj) {
        result = [[NSNull null] isEqual:obj] ? nil : (SKYRecord *)obj;
    } else {
        result = [_records objectForKey:recordID];
    }
    return [result copy];
}

- (NSArray *)recordIDsWithRecordType:(NSString *)recordType
{
    NSMutableArray *wantedRecordIDs = [[NSMutableArray alloc] init];
    [self enumerateRecordsWithBlock:^(SKYRecord *record, BOOL *stop) {
        if ([record.recordType isEqualToString:recordType]) {
            [wantedRecordIDs addObject:record.deprecatedID];
        }
    }];
    return wantedRecordIDs;
}

- (void)enumerateRecordsWithBlock:(void (^)(SKYRecord *, BOOL *))block
{
    if (!block) {
        return;
    }

    [_records enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        if ([self->_localRecords objectForKey:key]) {
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
                      usingBlock:(void (^)(SKYRecord *, BOOL *))block
{
    if (!block) {
        return;
    }

    NSMutableArray *result = [[NSMutableArray alloc] init];
    [self enumerateRecordsWithBlock:^(SKYRecord *record, BOOL *stop) {
        if ([recordType isEqualToString:record.recordType] &&
            (!predicate || [predicate evaluateWithObject:record])) {
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

- (void)appendChange:(SKYRecordChange *)change
{
    [_changes addObject:change];
    [self synchronize];
}

- (void)removeChange:(SKYRecordChange *)change
{
    [_changes removeObject:change];
    [self synchronize];
}

- (void)setFinishedWithError:(NSError *)error change:(SKYRecordChange *)change
{
    change.finished = YES;
    change.error = error;
    [self synchronize];
}

- (SKYRecordChange *)changeWithRecordID:(SKYRecordID *)recordID
{
    for (SKYRecordChange *change in _changes) {
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
    return
        [_changes filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"finished = NO"]];
}

- (NSArray *)failedChanges
{
    return [_changes
        filteredArrayUsingPredicate:[NSPredicate
                                        predicateWithFormat:@"finished = YES AND error != NULL"]];
}

@end

#pragma GCC diagnostic pop
