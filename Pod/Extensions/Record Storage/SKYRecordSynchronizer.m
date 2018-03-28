//
//  SKYRecordSynchronizer.m
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

#import "SKYRecordSynchronizer.h"
#import "SKYDeleteRecordsOperation.h"
#import "SKYModifyRecordsOperation.h"
#import "SKYQueryOperation.h"
#import "SKYRecordChange.h"
#import "SKYRecordStorage.h"
#import "SKYRecordStorage_Private.h"

@implementation SKYRecordSynchronizer {
    BOOL _updating;
    NSMutableDictionary *_changesUpdating;
}

- (instancetype)initWithContainer:(SKYContainer *)container
                         database:(SKYDatabase *)database
                            query:(SKYQuery *)query
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

- (void)triggerUpdateWithRecordStorage:(SKYRecordStorage *)storage
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

- (void)setUpdateAvailableWithRecordStorage:(SKYRecordStorage *)storage
                               notification:(SKYNotification *)note
{
    storage.hasUpdateAvailable = YES;
    if (storage.enabled) {
        [self triggerUpdateWithRecordStorage:storage];
    } else {
        NSLog(@"Update is available but record storage is not enabled. Storage: %@.", storage);
    }
}

- (void)recordStorageFetchUpdates:(SKYRecordStorage *)storage
                completionHandler:(void (^)(BOOL finished, NSError *error))completionHandler
{
    NSAssert(self.query, @"currently only support syncing with query.");

    if (_updating) {
        if (completionHandler) {
            NSError *error = [NSError
                errorWithDomain:@"SKYRecordStorageErrorDomain"
                           code:0
                       userInfo:@{
                           NSLocalizedDescriptionKey : NSLocalizedString(@"Already updating.", nil)
                       }];
            completionHandler(NO, error);
        }
        return;
    }

    SKYQueryOperation *op = [[SKYQueryOperation alloc] initWithQuery:self.query];
    op.queryRecordsCompletionBlock =
        ^(NSArray *fetchedRecords, SKYQueryCursor *cursor, NSError *operationError) {
            [storage beginUpdating];
            if (!operationError) {
                NSLog(@"%@: Updating record storage by replacing with %lu records.", self,
                      (unsigned long)[fetchedRecords count]);
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

- (SKYRecord *)_constructRecordForSavingWithStorage:(SKYRecordStorage *)storage
                                             change:(SKYRecordChange *)change
{
    SKYRecord *recordToSave = [storage.backingStore fetchRecordWithRecordID:change.recordID];
    if (recordToSave) {
        [change.attributesToSave enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            recordToSave[key] = obj[1];
        }];
    } else {
        NSMutableDictionary *attributes = [NSMutableDictionary dictionary];
        [change.attributesToSave enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            attributes[key] = obj[1];
        }];
        recordToSave = [[SKYRecord alloc] initWithRecordID:change.recordID data:attributes];
    }
    return recordToSave;
}

- (void)recordStorage:(SKYRecordStorage *)storage
          saveChanges:(NSArray *)changes
    completionHandler:(void (^)(BOOL finished, NSError *error))completionHandler;
{
    if (_updating) {
        if (completionHandler) {
            NSError *error = [NSError
                errorWithDomain:@"SKYRecordStorageErrorDomain"
                           code:0
                       userInfo:@{
                           NSLocalizedDescriptionKey : NSLocalizedString(@"Already updating.", nil)
                       }];
            completionHandler(NO, error);
        }
        return;
    }

    _updating = YES;

    __block NSInteger updateCount = 0;

    [changes enumerateObjectsUsingBlock:^(SKYRecordChange *change, NSUInteger idx, BOOL *stop) {
        if (change.action == SKYRecordChangeSave) {
            SKYRecord *recordToSave =
                [self _constructRecordForSavingWithStorage:storage change:change];

            SKYModifyRecordsOperation *op =
                [[SKYModifyRecordsOperation alloc] initWithRecordsToSave:@[ recordToSave ]];
            op.perRecordCompletionBlock = ^(SKYRecord *record, NSError *error) {
                if (!storage.updating) {
                    [storage beginUpdatingForChanges:YES];
                }
                [storage updateByApplyingChange:change recordOnRemote:record error:error];
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
        } else if (change.action == SKYRecordChangeDelete) {
            SKYDeleteRecordsOperation *op =
                [[SKYDeleteRecordsOperation alloc] initWithRecordIDsToDelete:@[ change.recordID ]];
            op.perRecordCompletionBlock = ^(SKYRecordID *recordID, NSError *error) {
                if (!storage.updating) {
                    [storage beginUpdatingForChanges:YES];
                }
                [storage updateByApplyingChange:change recordOnRemote:nil error:error];
            };
            op.deleteRecordsCompletionBlock =
                ^(NSArray *deletedRecordIDs, NSError *operationError) {
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

- (BOOL)isProcessingChange:(SKYRecordChange *)change storage:(SKYRecordStorage *)storage
{
    return (BOOL)[_changesUpdating objectForKey:change.recordID];
}

@end
