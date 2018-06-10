//
//  SKYDatabase.m
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

#import "SKYDatabase.h"

#import "SKYDatabaseOperation.h"
#import "SKYDeleteRecordsOperation.h"
#import "SKYDeleteSubscriptionsOperation.h"
#import "SKYError.h"
#import "SKYFetchRecordsOperation.h"
#import "SKYFetchSubscriptionsOperation.h"
#import "SKYGetAssetPostRequestOperation.h"
#import "SKYModifyRecordsOperation.h"
#import "SKYModifySubscriptionsOperation.h"
#import "SKYPostAssetOperation.h"
#import "SKYQueryCache.h"
#import "SKYQueryOperation.h"
#import "SKYRecordID.h"
#import "SKYRecord_Private.h"

@interface SKYDatabase ()

@property (nonatomic, readonly) NSMutableArray /* SKYDatabaseOperation */ *pendingOperations;
@property (nonatomic, readonly) NSOperationQueue *operationQueue;
@property (nonatomic, strong, readwrite) SKYContainer *container;

@end

@implementation SKYDatabase {
    NSString *_databaseID;
}

- (instancetype)initWithContainer:(SKYContainer *)container databaseID:(NSString *)databaseID
{
    self = [super init];
    if (self) {
        _container = container;
        _pendingOperations = [NSMutableArray array];
        _databaseID = databaseID;
        _operationQueue = [[NSOperationQueue alloc] init];
        _operationQueue.name = @"SKYDatabaseQueue";
    }
    return self;
}

- (void)addOperation:(SKYDatabaseOperation *)operation
{
    [self.pendingOperations addObject:operation];
}

- (void)executeOperation:(SKYDatabaseOperation *)operation
{
    operation.database = self;
    operation.container = self.container;
    [self.operationQueue addOperation:operation];
}

- (void)commit
{
    [self.operationQueue addOperations:self.pendingOperations waitUntilFinished:NO];
    [self.pendingOperations removeAllObjects];
}

- (NSString *)currentUserRecordID
{
    return [self.container.auth currentUserRecordID];
}

#pragma mark - Subscriptions

- (void)fetchAllSubscriptionsWithCompletionHandler:(void (^)(NSArray *, NSError *))completionHandler
{
    SKYFetchSubscriptionsOperation *operation = [SKYFetchSubscriptionsOperation
        fetchAllSubscriptionsOperationWithDeviceID:self.container.push.registeredDeviceID];
    if (completionHandler) {
        operation.fetchSubscriptionsCompletionBlock =
            ^(NSDictionary *subscriptionsBySubscriptionID, NSError *operationError) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    completionHandler([subscriptionsBySubscriptionID allValues], operationError);
                });
            };
    }

    [self executeOperation:operation];
}

- (void)fetchSubscriptionWithID:(NSString *)subscriptionID
              completionHandler:(void (^)(SKYSubscription *, NSError *))completionHandler
{
    SKYFetchSubscriptionsOperation *operation =
        [SKYFetchSubscriptionsOperation operationWithDeviceID:self.container.push.registeredDeviceID
                                              subscriptionIDs:@[ subscriptionID ]];
    if (completionHandler) {
        operation.fetchSubscriptionsCompletionBlock =
            ^(NSDictionary *subscriptionsBySubscriptionID, NSError *operationError) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSArray *subscriptions = [subscriptionsBySubscriptionID allValues];
                    if ([subscriptions count] > 0) {
                        completionHandler([subscriptions firstObject], operationError);
                    } else {
                        completionHandler(nil, operationError);
                    }
                });
            };
    }

    [self executeOperation:operation];
}

- (void)saveSubscription:(SKYSubscription *)subscription
       completionHandler:(void (^)(SKYSubscription *subscription, NSError *error))completionHandler
{
    SKYModifySubscriptionsOperation *operation = [SKYModifySubscriptionsOperation
        operationWithDeviceID:self.container.push.registeredDeviceID
          subscriptionsToSave:@[ subscription ]];
    if (completionHandler) {
        operation.modifySubscriptionsCompletionBlock =
            ^(NSArray *savedSubscriptions, NSError *operationError) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    SKYSubscription *subscription = nil;
                    if (!operationError) {
                        subscription = savedSubscriptions[0];
                    }

                    completionHandler(subscription, operationError);
                });
            };
    }

    [self executeOperation:operation];
}

- (void)deleteSubscriptionWithID:(NSString *)subscriptionID
               completionHandler:
                   (void (^)(NSString *subscriptionID, NSError *error))completionHandler
{
    SKYDeleteSubscriptionsOperation *operation = [SKYDeleteSubscriptionsOperation
          operationWithDeviceID:self.container.push.registeredDeviceID
        subscriptionIDsToDelete:@[ subscriptionID ]];
    if (completionHandler) {
        operation.deleteSubscriptionsCompletionBlock =
            ^(NSArray *deletedSubscriptionIDs, NSError *operationError) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSString *subscriptionID = nil;
                    if (!operationError) {
                        subscriptionID = deletedSubscriptionIDs[0];
                    }

                    completionHandler(subscriptionID, operationError);
                });
            };
    }

    [self executeOperation:operation];
}

#pragma mark - Convenient methods for record operations

- (NSArray *_Nonnull)findObjectsOfClass:(Class)klass inSKYObject:(id _Nonnull)obj
{
    if (!obj) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException
                                       reason:@"obj cannot be nil"
                                     userInfo:nil];
    }

    NSMutableArray *wanted = [[NSMutableArray alloc] init];
    NSMutableArray<id> *stack = [[NSMutableArray alloc] initWithObjects:obj, nil];

    while ([stack count]) {
        id item = [stack lastObject];
        [stack removeLastObject];

        if ([item isKindOfClass:klass]) {
            [wanted addObject:item];
        } else if ([item isKindOfClass:[SKYRecord class]]) {
            [stack addObject:[(SKYRecord *)item dictionary]];
        } else if ([item isKindOfClass:[NSDictionary class]]) {
            [stack addObjectsFromArray:[(NSDictionary *)item allValues]];
        } else if ([item isKindOfClass:[NSArray class]]) {
            [stack addObjectsFromArray:(NSArray *)item];
        }
    }
    return wanted;
}

- (void)sky_presave:(id _Nullable)object
         completion:(void (^_Nullable)(NSError *_Nullable error))completion
{
    if (!object) {
        if (completion) {
            completion(nil);
            return;
        }
    }

    // Presave Record
    NSArray<SKYRecord *> *records = [self findObjectsOfClass:[SKYRecord class] inSKYObject:object];
    for (SKYRecord *record in records) {
        if (!record.creationDate) {
            record.creationDate = [NSDate date];
        }
    }

    // Presave Asset
    NSArray<SKYAsset *> *assets = [self findObjectsOfClass:[SKYAsset class] inSKYObject:object];
    NSMutableArray<NSError *> *errors = [[NSMutableArray alloc] init];

    dispatch_group_t upload_group = dispatch_group_create();
    for (SKYAsset *asset in assets) {
        dispatch_group_enter(upload_group);
        [self uploadAsset:asset
            completionHandler:^(SKYAsset *a, NSError *error) {
                if (error) {
                    [errors addObject:error];
                }
                dispatch_group_leave(upload_group);
            }];
    }

    dispatch_group_notify(upload_group, dispatch_get_main_queue(), ^{
        if (completion) {
            if ([errors count] > 0) {
                completion([errors firstObject]);
            } else {
                completion(nil);
            }
        }
    });
}

- (void)sky_saveRecords:(NSArray<SKYRecord *> *)records
             atomically:(BOOL)atomically
             completion:(void (^)(NSArray *, NSError *))completion
    perRecordCompletion:(void (^)(SKYRecord *, NSError *))perRecord
{
    dispatch_group_t save_group = dispatch_group_create();
    dispatch_group_enter(save_group);
    __block NSError *lastError = nil;
    [self sky_presave:records
           completion:^(NSError *error) {
               lastError = error;
               dispatch_group_leave(save_group);
           }];

    SKYModifyRecordsOperation *operation =
        [[SKYModifyRecordsOperation alloc] initWithRecordsToSave:records];
    operation.atomic = atomically;
    if (completion) {
        operation.modifyRecordsCompletionBlock = ^(NSArray *savedRecords, NSError *operationError) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(savedRecords, operationError);
            });
        };
    }

    if (perRecord) {
        operation.perRecordCompletionBlock = ^(SKYRecord *record, NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                perRecord(record, error);
            });
        };
    }

    dispatch_group_notify(save_group, dispatch_get_main_queue(), ^{
        if (lastError) {
            if (completion) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    completion(nil, lastError);
                });
            }
            return;
        }

        [self executeOperation:operation];
    });
}

- (void)saveRecord:(SKYRecord *)record completion:(SKYRecordSaveCompletion)completion
{
    [self sky_saveRecords:@[ record ]
        atomically:NO
        completion:^(NSArray *records, NSError *error) {
            if (error != nil && error.code != SKYErrorPartialOperationFailure) {
                if (completion) {
                    completion(nil, error);
                }
            }
        }
        perRecordCompletion:^(SKYRecord *record, NSError *error) {
            if (completion) {
                completion(record, error);
            }
        }];
}

- (void)saveRecords:(NSArray *)records
        completionHandler:(void (^)(NSArray *, NSError *))completionHandler
    perRecordErrorHandler:(void (^)(SKYRecord *, NSError *))errorHandler
{
    [self sky_saveRecords:records
                 atomically:NO
                 completion:completionHandler
        perRecordCompletion:^(SKYRecord *record, NSError *error) {
            if (errorHandler && error) {
                errorHandler(record, error);
            }
        }];
}

- (void)saveRecordsAtomically:(NSArray *)records
            completionHandler:
                (void (^)(NSArray *savedRecords, NSError *operationError))completionHandler
{
    [self sky_saveRecords:records
                 atomically:YES
                 completion:completionHandler
        perRecordCompletion:nil];
}

- (void)fetchRecordWithID:(SKYRecordID *)recordID
        completionHandler:(void (^)(SKYRecord *record, NSError *error))completionHandler
{
    SKYFetchRecordsOperation *operation =
        [[SKYFetchRecordsOperation alloc] initWithRecordIDs:@[ recordID ]];

    if (completionHandler) {
        operation.fetchRecordsCompletionBlock =
            ^(NSDictionary *recordsByRecordID, NSError *operationError) {
                SKYRecord *record = recordsByRecordID[recordID];
                NSError *error = nil;
                if (operationError != nil) {
                    if (operationError.code == SKYErrorPartialOperationFailure) {
                        error = operationError.userInfo[SKYPartialErrorsByItemIDKey][recordID];
                    }

                    // If error is not a partial error, or if the error cannot be obtained
                    // from the info dictionary, set the returned error to the operationError.
                    if (!error) {
                        error = operationError;
                    }
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    completionHandler(record, error);
                });
            };
    }

    [self executeOperation:operation];
}

- (void)fetchRecordsWithIDs:(NSArray *)recordIDs
          completionHandler:(void (^)(NSDictionary *, NSError *))completionHandler
      perRecordErrorHandler:(void (^)(SKYRecordID *, NSError *))errorHandler
{
    SKYFetchRecordsOperation *operation =
        [[SKYFetchRecordsOperation alloc] initWithRecordIDs:recordIDs];

    if (completionHandler) {
        operation.fetchRecordsCompletionBlock =
            ^(NSDictionary *recordsByRecordID, NSError *operationError) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    completionHandler(recordsByRecordID, operationError);
                });
            };
    }

    if (errorHandler) {
        operation.perRecordCompletionBlock =
            ^(SKYRecord *record, SKYRecordID *recordID, NSError *error) {
                if (error) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        errorHandler(recordID, error);

                    });
                }
            };
    }

    [self executeOperation:operation];
}

- (void)deleteRecordWithID:(SKYRecordID *)recordID
         completionHandler:(void (^)(SKYRecordID *recordID, NSError *error))completionHandler
{
    SKYDeleteRecordsOperation *operation =
        [[SKYDeleteRecordsOperation alloc] initWithRecordIDsToDelete:@[ recordID ]];

    if (completionHandler) {
        operation.deleteRecordsCompletionBlock = ^(NSArray *recordIDs, NSError *operationError) {
            SKYRecordID *deletedRecordID = nil;
            NSError *error = nil;
            if (operationError != nil) {
                if (operationError.code == SKYErrorPartialOperationFailure) {
                    error = operationError.userInfo[SKYPartialErrorsByItemIDKey][recordID];
                }

                // If error is not a partial error, or if the error cannot be obtained
                // from the info dictionary, set the returned error to the operationError.
                if (!error) {
                    error = operationError;
                }
            }
            if ([recordIDs count] > 0) {
                deletedRecordID = recordIDs[0];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                completionHandler(deletedRecordID, error);
            });
        };
    }

    [self executeOperation:operation];
}

- (void)deleteRecordsWithIDs:(NSArray *)recordIDs
           completionHandler:(void (^)(NSArray *, NSError *))completionHandler
       perRecordErrorHandler:(void (^)(SKYRecordID *, NSError *))errorHandler
{
    SKYDeleteRecordsOperation *operation =
        [[SKYDeleteRecordsOperation alloc] initWithRecordIDsToDelete:recordIDs];

    if (completionHandler) {
        operation.deleteRecordsCompletionBlock = ^(NSArray *recordIDs, NSError *operationError) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completionHandler(recordIDs, operationError);
            });
        };
    }

    if (errorHandler) {
        operation.perRecordCompletionBlock = ^(SKYRecordID *deletedRecordID, NSError *error) {
            if (error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    errorHandler(deletedRecordID, error);
                });
            }
        };
    }

    [self executeOperation:operation];
}

- (void)deleteRecordsWithIDsAtomically:(NSArray *)recordIDs
                     completionHandler:
                         (void (^)(NSArray *deletedRecordIDs, NSError *error))completionHandler
{
    SKYDeleteRecordsOperation *operation =
        [[SKYDeleteRecordsOperation alloc] initWithRecordIDsToDelete:recordIDs];
    operation.atomic = YES;

    if (completionHandler) {
        operation.deleteRecordsCompletionBlock = ^(NSArray *recordIDs, NSError *operationError) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completionHandler(recordIDs, operationError);
            });
        };
    }

    [self executeOperation:operation];
}

- (void)performQuery:(SKYQuery *)query
    completionHandler:(void (^)(NSArray *, NSError *))completionHandler
{
    SKYQueryOperation *operation = [[SKYQueryOperation alloc] initWithQuery:query];

    if (completionHandler) {
        operation.queryRecordsCompletionBlock =
            ^(NSArray *fetchedRecords, SKYQueryCursor *cursor, NSError *operationError) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    completionHandler(fetchedRecords, operationError);
                });
            };
    }

    [self executeOperation:operation];
}

- (void)performCachedQuery:(SKYQuery *)query
         completionHandler:(void (^)(NSArray *, BOOL, NSError *))completionHandler
{
    SKYQueryCache *cache = [[SKYQueryCache alloc] initWithDatabase:self];
    NSArray *cachedResults = [cache cachedResultsWithQuery:query];
    if (cachedResults && completionHandler) {
        completionHandler(cachedResults, YES, nil);
    }

    [self performQuery:query
        completionHandler:^(NSArray *results, NSError *error) {
            if (error) {
                if (completionHandler) {
                    completionHandler(cachedResults, NO, error);
                }
            } else {
                [cache cacheQuery:query results:results];
                if (completionHandler) {
                    completionHandler(results, NO, nil);
                }
            }
        }];
}

- (void)uploadAsset:(SKYAsset *)asset
    completionHandler:(void (^)(SKYAsset *, NSError *))completionHandler
{
    __weak typeof(self) wself = self;

    if ([asset.fileSize integerValue] == 0) {
        if (completionHandler) {
            completionHandler(
                nil, [NSError errorWithDomain:SKYOperationErrorDomain
                                         code:SKYErrorInvalidArgument
                                     userInfo:@{
                                         SKYErrorMessageKey : @"File size is invalid (filesize=0).",
                                         NSLocalizedDescriptionKey : NSLocalizedString(
                                             @"Unable to open file or file is not found.", nil)
                                     }]);
        }
        return;
    }

    SKYGetAssetPostRequestOperation *operation =
        [SKYGetAssetPostRequestOperation operationWithAsset:asset];
    operation.getAssetPostRequestCompletionBlock = ^(
        SKYAsset *asset, NSURL *postURL, NSDictionary<NSString *, NSObject *> *extraFields,
        NSError *operationError) {
        if (operationError) {
            if (completionHandler) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    completionHandler(asset, operationError);
                });
            }

            return;
        }

        SKYPostAssetOperation *postOperation =
            [SKYPostAssetOperation operationWithAsset:asset url:postURL extraFields:extraFields];
        postOperation.postAssetCompletionBlock = ^(SKYAsset *asset, NSError *postOperationError) {
            if (completionHandler) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    completionHandler(asset, postOperationError);
                });
            }
        };

        [wself.container addOperation:postOperation];
    };

    [self.container addOperation:operation];
}

@end
