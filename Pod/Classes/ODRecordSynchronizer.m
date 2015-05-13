//
//  ODRecordSynchronizer.m
//  Pods
//
//  Created by atwork on 12/5/15.
//
//

#import "ODRecordSynchronizer.h"
#import "ODRecordStorage.h"
#import "ODModifyRecordsOperation.h"
#import "ODDeleteRecordsOperation.h"
#import "ODQueryOperation.h"
#import "ODRecordChange_Private.h"

@implementation ODRecordSynchronizer

- (instancetype)initWithContainer:(ODContainer *)container
                         database:(ODDatabase *)database
                            query:(ODQuery *)query
{
    self = [super init];
    if (self) {
        _container = container;
        _database = database;
        _query = query;
    }
    return self;
}

- (void)recordStorageFetchUpdates:(ODRecordStorage *)storage
{
    NSAssert(self.query, @"currently only support syncing with query.");
    
    ODQueryOperation *op = [[ODQueryOperation alloc] initWithQuery:self.query];
    op.queryRecordsCompletionBlock = ^(NSArray *fetchedRecords, ODQueryCursor *cursor,
                                       NSError *operationError) {
        if (!operationError) {
            [storage beginUpdating];
            [storage updateByReplacingWithRecords:fetchedRecords];
            [storage finishUpdating];
        }
    };
    [self.database executeOperation:op];
}

- (ODRecord *)_constructRecordForSavingWithStorage:(ODRecordStorage *)storage
                                       change:(ODRecordChange *)change
{
    ODRecord *recordToSave = [storage.backingStore fetchRecordWithRecordID:change.recordID];
    if (recordToSave) {
        [change.attributesToSave
         enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
             recordToSave[key] = obj;
         }];
    } else {
        NSMutableDictionary *attributes = [NSMutableDictionary dictionary];
        [change.attributesToSave
         enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
             attributes[key] = obj[1];
         }];
        recordToSave = [[ODRecord alloc] initWithRecordID:change.recordID data:attributes];
    }
    return recordToSave;
}

- (void)recordStorage:(ODRecordStorage *)storage
          saveChanges:(NSArray *)changes;
{
    [changes enumerateObjectsUsingBlock:^(ODRecordChange *change, NSUInteger idx, BOOL *stop) {
        if (change.action == ODRecordChangeSave) {
            ODRecord *recordToSave = [self _constructRecordForSavingWithStorage:storage
                                                                         change:change];
            
            ODModifyRecordsOperation *op = [[ODModifyRecordsOperation alloc]
                                            initWithRecordsToSave:@[recordToSave]];
            op.perRecordCompletionBlock = ^(ODRecord *record, NSError *error) {
                if (!storage.updating) {
                    [storage beginUpdating];
                }
                [storage updateByApplyingChange:change
                                 recordOnRemote:record
                                          error:error];
            };
            op.modifyRecordsCompletionBlock = ^(NSArray *savedRecords, NSError *operationError) {
                [storage finishUpdating];
            };
            change.state = ODRecordChangeStateStarted;
            [self.database executeOperation:op];
        } else if (change.action == ODRecordChangeDelete) {
            ODDeleteRecordsOperation *op = [[ODDeleteRecordsOperation alloc]
                                            initWithRecordIDsToDelete:@[change.recordID]];
            op.perRecordCompletionBlock = ^(ODRecordID *recordID, NSError *error) {
                if (!storage.updating) {
                    [storage beginUpdating];
                }
                [storage updateByApplyingChange:change
                                 recordOnRemote:nil
                                          error:error];
            };
            op.deleteRecordsCompletionBlock = ^(NSArray *deletedRecordIDs,
                                                NSError *operationError) {
                [storage finishUpdating];
            };
            change.state = ODRecordChangeStateStarted;
            [self.database executeOperation:op];
        }

    }];
}


@end
