//
//  ODRecordSynchronizer.m
//  Pods
//
//  Created by atwork on 12/5/15.
//
//

#import "ODRecordSynchronizer.h"
#import "ODRecordStorage.h"
#import "ODRecordStorage_Private.h"
#import "ODModifyRecordsOperation.h"
#import "ODDeleteRecordsOperation.h"
#import "ODQueryOperation.h"
#import "ODRecordChange.h"

@implementation ODRecordSynchronizer {
    BOOL _updating;
}

- (instancetype)initWithContainer:(ODContainer *)container
                         database:(ODDatabase *)database
                            query:(ODQuery *)query
{
    self = [super init];
    if (self) {
        _container = container;
        _database = database;
        _query = query;
        _updating = NO;
    }
    return self;
}

- (void)triggerUpdateWithRecordStorage:(ODRecordStorage *)storage
{
    if (_updating) {
        return;
    }
    
    if (storage.hasPendingChanges) {
        [self recordStorage:storage saveChanges:storage.pendingChanges];
    } else if (storage.hasUpdateAvailable) {
        [self recordStorageFetchUpdates:storage];
    }
}


- (void)setUpdateAvailableWithRecordStorage:(ODRecordStorage *)storage
                               notification:(ODNotification *)note
{
    storage.hasUpdateAvailable = YES;
    if (storage.enabled) {
        [self triggerUpdateWithRecordStorage:storage];
    } else {
        NSLog(@"Update is available but record storage is not enabled. Storage: %@.", storage);
    }
}

- (void)recordStorageFetchUpdates:(ODRecordStorage *)storage
{
    NSAssert(self.query, @"currently only support syncing with query.");
    
    if (_updating) {
        return;
    }
    
    ODQueryOperation *op = [[ODQueryOperation alloc] initWithQuery:self.query];
    op.queryRecordsCompletionBlock = ^(NSArray *fetchedRecords, ODQueryCursor *cursor,
                                       NSError *operationError) {
        if (!operationError) {
            [storage beginUpdating];
            NSLog(@"%@: Updating record storage by replacing with %lu records.",
                  self, (unsigned long)[fetchedRecords count]);
            [storage updateByReplacingWithRecords:fetchedRecords];
            [storage finishUpdating];
            storage.hasUpdateAvailable = NO;
        }
        _updating = NO;
    };
    _updating = YES;
    [self.database executeOperation:op];
}

- (ODRecord *)_constructRecordForSavingWithStorage:(ODRecordStorage *)storage
                                       change:(ODRecordChange *)change
{
    ODRecord *recordToSave = [storage.backingStore fetchRecordWithRecordID:change.recordID];
    if (recordToSave) {
        [change.attributesToSave
         enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
             recordToSave[key] = obj[1];
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
    if (_updating) {
        return;
    }
    
    _updating = YES;
    
    __block NSInteger updateCount = 0;
    
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
                updateCount--;
                if (updateCount <= 0) {
                    _updating = NO;
                }
            };
            [storage.backingStore setState:ODRecordChangeStateStarted ofChange:change];
            updateCount++;
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
                updateCount--;
                if (updateCount <= 0) {
                    _updating = NO;
                }
            };
            [storage.backingStore setState:ODRecordChangeStateStarted ofChange:change];
            updateCount++;
            [self.database executeOperation:op];
        }

    }];
}


@end
