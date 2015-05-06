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

@implementation ODRecordStorageMemoryStore

- (instancetype)init
{
    self = [super init];
    if (self) {
        _records = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void)insertRecord:(ODRecord *)record
{
    [_records setObject:record forKey:record.recordID];
}

- (void)updateRecord:(ODRecord *)record
{
    [_records setObject:record forKey:record.recordID];
}

- (void)deleteRecord:(ODRecord *)record
{
    [_records removeObjectForKey:record.recordID];
}

- (BOOL)existsRecordWithRecordID:(ODRecordID *)recordID
{
    return (BOOL)[_records objectForKey:recordID];
}

- (ODRecord *)fetchRecordWithRecordID:(ODRecordID *)recordID
{
    return [_records objectForKey:recordID];
}

- (NSArray *)queryRecordIDsWithRecordType:(NSString *)recordType
{
    NSMutableArray *wantedRecordIDs = [[NSMutableArray alloc] init];
    [_records enumerateKeysAndObjectsUsingBlock:^(ODRecordID *key, ODRecord *obj, BOOL *stop) {
        NSAssert([key isKindOfClass:[ODRecordID class]],
                 @"%@ is expected to be an ODRecordID.", NSStringFromClass([key class]));
        if ([key.recordType isEqualToString:recordType]) {
            [wantedRecordIDs addObject:key];
        }
    }];
    return wantedRecordIDs;
}

- (void)synchronize
{
    // do nothing
}

@end
