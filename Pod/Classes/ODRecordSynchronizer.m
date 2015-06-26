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
    NSMutableDictionary *_changesUpdating;
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
        _changesUpdating = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)triggerUpdateWithRecordStorage:(ODRecordStorage *)storage
{
    if (_updating) {
        return;
    }
    
    if (storage.hasPendingChanges) {
        [self recordStorage:storage saveChanges:storage.pendingChanges completionHandler:nil];
    } else if (storage.hasUpdateAvailable) {
        [self recordStorageFetchUpdates:storage completionHandler:nil];
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

- (void)recordStorageFetchUpdates:(ODRecordStorage *)storage completionHandler:(void(^)(BOOL finished, NSError *error))completionHandler
{
    NSAssert(self.query, @"currently only support syncing with query.");
    
    if (_updating) {
        if (completionHandler) {
            NSError *error = [NSError errorWithDomain:@"ODRecordStorageErrorDomain"
                                                 code:0
                                             userInfo:@{
                                                        NSLocalizedDescriptionKey: @"Already updating."
                                                        }];
            completionHandler(NO, error);
        }
        return;
    }
    
    ODQueryOperation *op = [[ODQueryOperation alloc] initWithQuery:self.query];
    op.queryRecordsCompletionBlock = ^(NSArray *fetchedRecords, ODQueryCursor *cursor,
                                       NSError *operationError) {
        [storage beginUpdating];
        if (!operationError) {
            NSLog(@"%@: Updating record storage by replacing with %lu records.",
                  self, (unsigned long)[fetchedRecords count]);
            [storage updateByReplacingWithRecords:fetchedRecords];
            storage.hasUpdateAvailable = NO;
        }
        [storage finishUpdating];
        _updating = NO;
        
        if (completionHandler) {
            completionHandler(YES, nil);
        }
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
          saveChanges:(NSArray *)changes
    completionHandler:(void (^)(BOOL finished, NSError *error))completionHandler;
{
    if (_updating) {
        if (completionHandler) {
            NSError *error = [NSError errorWithDomain:@"ODRecordStorageErrorDomain"
                                                 code:0
                                             userInfo:@{
                                                        NSLocalizedDescriptionKey: @"Already updating."
                                                        }];
            completionHandler(NO, error);
        }
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
                    [storage beginUpdatingForChanges:YES];
                }
                [storage updateByApplyingChange:change
                                 recordOnRemote:record
                                          error:error];
            };
            op.modifyRecordsCompletionBlock = ^(NSArray *savedRecords, NSError *operationError) {
                if (storage.updating) {
                    [storage finishUpdating];
                }
                [_changesUpdating removeObjectForKey:change.recordID];
                updateCount--;
                if (updateCount <= 0) {
                    _updating = NO;
                    if (completionHandler) {
                        completionHandler(YES, nil);
                    }
                }
            };
            [_changesUpdating setObject:change forKey:change.recordID];
            updateCount++;
            [self.database executeOperation:op];
        } else if (change.action == ODRecordChangeDelete) {
            ODDeleteRecordsOperation *op = [[ODDeleteRecordsOperation alloc]
                                            initWithRecordIDsToDelete:@[change.recordID]];
            op.perRecordCompletionBlock = ^(ODRecordID *recordID, NSError *error) {
                if (!storage.updating) {
                    [storage beginUpdatingForChanges:YES];
                }
                [storage updateByApplyingChange:change
                                 recordOnRemote:nil
                                          error:error];
            };
            op.deleteRecordsCompletionBlock = ^(NSArray *deletedRecordIDs,
                                                NSError *operationError) {
                if (storage.updating) {
                    [storage finishUpdating];
                }
                [_changesUpdating removeObjectForKey:change.recordID];
                updateCount--;
                if (updateCount <= 0) {
                    _updating = NO;
                    if (completionHandler) {
                        completionHandler(YES, nil);
                    }
                }
            };
            [_changesUpdating setObject:change forKey:change.recordID];
            updateCount++;
            [self.database executeOperation:op];
        }

    }];
}

- (BOOL)isProcessingChange:(ODRecordChange *)change storage:(ODRecordStorage *)storage
{
    return (BOOL)[_changesUpdating objectForKey:change.recordID];
}


@end
