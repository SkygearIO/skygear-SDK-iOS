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

@property (nonatomic, readonly) NSMutableArray<SKYDatabaseOperation *> *pendingOperations;
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

#pragma mark Support on pre-saving

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

- (id _Nonnull)replaceSKYObject:(id _Nonnull)obj fromMap:(NSMapTable *_Nonnull)mapTable
{
    id replacedObj = [mapTable objectForKey:obj];
    if (replacedObj != nil) {
        return replacedObj;
    }

    if ([obj isKindOfClass:[SKYRecord class]]) {
        SKYRecord *record = [(SKYRecord *)obj copy];
        for (NSString *key in [[record dictionary] allKeys]) {
            [record setObject:[self replaceSKYObject:[record objectForKey:key] fromMap:mapTable]
                       forKey:key];
        }
        return record;
    } else if ([obj isKindOfClass:[NSDictionary class]]) {
        NSMutableDictionary *dict = [(NSDictionary *)obj mutableCopy];
        for (NSString *key in [dict allKeys]) {
            [dict setObject:[self replaceSKYObject:[dict objectForKey:key] fromMap:mapTable]
                     forKey:key];
        }
        return dict;
    } else if ([obj isKindOfClass:[NSArray class]]) {
        NSMutableArray *array = [(NSArray *)obj mutableCopy];
        for (NSUInteger i = 0; i < [array count]; i++) {
            [array replaceObjectAtIndex:i
                             withObject:[self replaceSKYObject:[array objectAtIndex:i]
                                                       fromMap:mapTable]];
        }
        return array;
    }
    return obj;
}

- (void)sky_presave:(id _Nullable)object
         completion:(void (^_Nullable)(id _Nullable, NSError *_Nullable))completion
{
    if (!object) {
        if (completion) {
            completion(nil, nil);
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
    NSMutableArray<SKYAsset *> *assetsToSave = [NSMutableArray array];
    for (SKYAsset *asset in [self findObjectsOfClass:[SKYAsset class] inSKYObject:object]) {
        if (asset.url.isFileURL) {
            [assetsToSave addObject:asset];
        }
    }

    NSMapTable<SKYAsset *, SKYAsset *> *uploadedAssets = [[NSMapTable alloc] init];
    NSMutableArray<NSError *> *uploadErrors = [[NSMutableArray alloc] init];

    dispatch_group_t upload_group = dispatch_group_create();
    for (SKYAsset *asset in assetsToSave) {
        dispatch_group_enter(upload_group);
        [self uploadAsset:asset
            completionHandler:^(SKYAsset *uploadedAsset, NSError *error) {
                if (error) {
                    [uploadErrors addObject:error];
                    return;
                }
                [uploadedAssets setObject:uploadedAsset forKey:asset];
                dispatch_group_leave(upload_group);
            }];
    }

    dispatch_group_notify(upload_group, dispatch_get_main_queue(), ^{
        if (!completion) {
            return;
        }

        if (uploadErrors.count) {
            completion(nil, uploadErrors.firstObject);
        } else {
            completion([self replaceSKYObject:object fromMap:uploadedAssets], nil);
        }
    });
}

- (void)sky_saveRecords:(NSArray<SKYRecord *> *)records
             atomically:(BOOL)atomically
             completion:(void (^)(NSArray<SKYRecordResult<SKYRecord *> *> *, NSError *))completion
{
    dispatch_group_t save_group = dispatch_group_create();
    dispatch_group_enter(save_group);
    __block NSError *lastError = nil;
    __block NSArray *presavedRecords = nil;
    [self sky_presave:records
           completion:^(id _Nullable presavedObject, NSError *_Nullable error) {
               lastError = error;
               presavedRecords = (NSArray *)presavedObject;
               dispatch_group_leave(save_group);
           }];

    dispatch_group_notify(save_group, dispatch_get_main_queue(), ^{
        if (lastError) {
            if (completion) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    completion(nil, lastError);
                });
            }
            return;
        }

        SKYModifyRecordsOperation *operation =
            [[SKYModifyRecordsOperation alloc] initWithRecords:presavedRecords];
        operation.atomic = atomically;
        if (completion) {
            operation.modifyRecordsCompletionBlock =
                ^(NSArray<SKYRecordResult<SKYRecord *> *> *savedRecords, NSError *operationError) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        completion(savedRecords, operationError);
                    });
                };
        }

        [self executeOperation:operation];
    });
}

#pragma mark Public methods for records

- (void)saveRecord:(SKYRecord *)record
        completion:(void (^_Nullable)(SKYRecord *_Nullable, NSError *_Nullable))completion
{
    [self sky_saveRecords:@[ record ]
               atomically:NO
               completion:^(NSArray<SKYRecordResult<SKYRecord *> *> *results,
                            NSError *operationError) {
                   if (!completion) {
                       return;
                   }
                   if (operationError) {
                       completion(nil, operationError);
                   } else {
                       completion(results.firstObject.value, results.firstObject.error);
                   }
               }];
}

- (void)saveRecords:(NSArray<SKYRecord *> *)records
         completion:(void (^_Nullable)(NSArray *_Nullable savedRecords,
                                       NSError *_Nullable operationError))completion
{
    [self sky_saveRecords:records
               atomically:YES
               completion:^(NSArray<SKYRecordResult<SKYRecord *> *> *results, NSError *error) {
                   if (!completion) {
                       return;
                   }
                   if (error) {
                       completion(nil, error);
                   } else {
                       NSMutableArray<SKYRecord *> *records = [NSMutableArray array];
                       for (SKYRecordResult<SKYRecord *> *result in results) {
                           if (!result.value) {
                               continue;
                           }
                           [records addObject:result.value];
                       }
                       completion(records, nil);
                   }
               }];
}

- (void)saveRecordsNonAtomically:(NSArray<SKYRecord *> *)records
                      completion:
                          (void (^_Nullable)(NSArray<SKYRecordResult<SKYRecord *> *> *savedRecords,
                                             NSError *_Nullable operationError))completion
{
    [self sky_saveRecords:records atomically:NO completion:completion];
}

- (void)fetchRecordWithType:(NSString *)recordType
                   recordID:(NSString *)recordID
                 completion:(void (^)(SKYRecord *record, NSError *error))completion
{
    SKYQuery *query =
        [SKYQuery queryWithRecordType:recordType
                            predicate:[NSPredicate predicateWithFormat:@"_id = %@", recordID]];
    [self performQuery:query
            completion:^(NSArray<SKYRecord *> *_Nullable results, SKYQueryInfo *_Nullable info,
                         NSError *_Nullable error) {
                if (!completion) {
                    return;
                }

                if (error) {
                    completion(nil, error);
                    return;
                }

                if ([results count] < 1) {
                    completion(nil, [NSError errorWithDomain:SKYOperationErrorDomain
                                                        code:SKYErrorResourceNotFound
                                                    userInfo:nil]);
                    return;
                }
                completion(results.firstObject, nil);
            }];
}

- (void)fetchRecordsWithType:(NSString *)recordType
                   recordIDs:(NSArray<NSString *> *)recordIDs
                  completion:
                      (void (^)(NSArray<SKYRecordResult<SKYRecord *> *> *, NSError *))completion
{
    SKYQuery *query =
        [SKYQuery queryWithRecordType:recordType
                            predicate:[NSPredicate predicateWithFormat:@"_id IN %@", recordIDs]];
    [self
        performQuery:query
          completion:^(NSArray<SKYRecord *> *_Nullable results, SKYQueryInfo *_Nullable info,
                       NSError *_Nullable error) {
              if (error) {
                  if (completion) {
                      completion(nil, error);
                  }
                  return;
              }

              NSMutableArray<NSString *> *remainingRecordIDs = [recordIDs mutableCopy];
              NSMutableDictionary<NSString *, SKYRecord *> *recordsByID =
                  [[NSMutableDictionary alloc] init];
              for (SKYRecord *record in results) {
                  [recordsByID setObject:record forKey:record.recordID];
                  [remainingRecordIDs removeObject:record.recordID];
              }

              NSMutableArray<SKYRecordResult<SKYRecord *> *> *fetchResults = [NSMutableArray array];
              for (NSString *recordID in recordIDs) {
                  SKYRecord *fetchedRecord = recordsByID[recordID];
                  if (fetchedRecord) {
                      [fetchResults addObject:[[SKYRecordResult<SKYRecord *> alloc]
                                                  initWithValue:fetchedRecord]];
                  } else {
                      NSError *notFound = [NSError errorWithDomain:SKYOperationErrorDomain
                                                              code:SKYErrorResourceNotFound
                                                          userInfo:nil];
                      [fetchResults
                          addObject:[[SKYRecordResult<SKYRecord *> alloc] initWithError:notFound]];
                  }
              }

              if (completion) {
                  completion(fetchResults, nil);
              }
          }];
}

- (void)sky_deleteRecordsWithType:(NSString *)recordType
                        recordIDs:(NSArray<NSString *> *)recordIDs
                       atomically:(BOOL)atomically
                       completion:(void (^)(NSArray<SKYRecordResult<NSString *> *> *_Nullable,
                                            NSError *_Nullable))completion
{
    SKYDeleteRecordsOperation *operation =
        [[SKYDeleteRecordsOperation alloc] initWithRecordType:recordType recordIDs:recordIDs];
    operation.atomic = atomically;

    if (completion) {
        operation.deleteRecordsCompletionBlock =
            ^(NSArray<SKYRecordResult<SKYRecord *> *> *results, NSError *operationError) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSMutableArray<SKYRecordResult<NSString *> *> *resultWithIDs =
                        [NSMutableArray array];
                    for (SKYRecordResult<SKYRecord *> *resultWithRecord in results) {
                        if (resultWithRecord.value) {
                            [resultWithIDs
                                addObject:[[SKYRecordResult<NSString *> alloc]
                                              initWithValue:resultWithRecord.value.recordID]];
                        } else {
                            [resultWithIDs addObject:[[SKYRecordResult<NSString *> alloc]
                                                         initWithError:resultWithRecord.error]];
                        }
                    }
                    completion(resultWithIDs, operationError);
                });
            };
    }

    [self executeOperation:operation];
}

- (void)deleteRecordWithType:(NSString *)recordType
                    recordID:(NSString *)recordID
                  completion:(void (^)(NSString *recordID, NSError *error))completion
{
    [self sky_deleteRecordsWithType:recordType
                          recordIDs:@[ recordID ]
                         atomically:NO
                         completion:^(NSArray<SKYRecordResult<NSString *> *> *_Nullable results,
                                      NSError *_Nullable operationError) {
                             if (!completion) {
                                 return;
                             }
                             if (operationError) {
                                 completion(nil, operationError);
                             } else {
                                 completion(results.firstObject.value, results.firstObject.error);
                             }
                         }];
}

- (void)deleteRecordsWithType:(NSString *)recordType
                    recordIDs:(NSArray<NSString *> *)recordIDs
                   completion:(void (^)(NSArray<NSString *> *, NSError *))completion
{
    [self sky_deleteRecordsWithType:recordType
                          recordIDs:recordIDs
                         atomically:YES
                         completion:^(NSArray<SKYRecordResult<NSString *> *> *_Nullable results,
                                      NSError *_Nullable operationError) {
                             if (!completion) {
                                 return;
                             }
                             if (operationError) {
                                 completion(nil, operationError);
                             } else {
                                 NSMutableArray<NSString *> *recordIDs = [NSMutableArray array];
                                 for (SKYRecordResult<NSString *> *result in results) {
                                     [recordIDs addObject:result.value];
                                 }
                                 completion(recordIDs, nil);
                             }
                         }];
}

- (void)deleteRecordsNonAtomicallyWithType:(NSString *)recordType
                                 recordIDs:(NSArray<NSString *> *)recordIDs
                                completion:(void (^_Nullable)(NSArray<SKYRecordResult<NSString *> *>
                                                                  *_Nullable deletedRecordIDs,
                                                              NSError *_Nullable error))completion;
{
    [self sky_deleteRecordsWithType:recordType
                          recordIDs:recordIDs
                         atomically:NO
                         completion:completion];
}

- (void)sky_deleteRecords:(NSArray<SKYRecord *> *)records
               atomically:(BOOL)atomically
               completion:(void (^)(NSArray<SKYRecordResult<SKYRecord *> *> *_Nullable,
                                    NSError *_Nullable))completion
{
    SKYDeleteRecordsOperation *operation =
        [[SKYDeleteRecordsOperation alloc] initWithRecords:records];
    operation.atomic = atomically;

    if (completion) {
        operation.deleteRecordsCompletionBlock =
            ^(NSArray<SKYRecordResult<SKYRecord *> *> *results, NSError *operationError) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    completion(results, operationError);
                });
            };
    }

    [self executeOperation:operation];
}

- (void)deleteRecord:(SKYRecord *)record
          completion:(void (^)(SKYRecord *_Nullable, NSError *_Nullable))completion
{
    [self sky_deleteRecords:@[ record ]
                 atomically:NO
                 completion:^(NSArray<SKYRecordResult<SKYRecord *> *> *_Nullable results,
                              NSError *_Nullable operationError) {
                     if (!completion) {
                         return;
                     }
                     if (operationError) {
                         completion(nil, operationError);
                     } else {
                         completion(results.firstObject.value, results.firstObject.error);
                     }
                 }];
}

- (void)deleteRecords:(NSArray<SKYRecord *> *)records
           completion:(void (^)(NSArray<SKYRecord *> *_Nullable, NSError *_Nullable))completion
{
    [self sky_deleteRecords:records
                 atomically:YES
                 completion:^(NSArray<SKYRecordResult<SKYRecord *> *> *_Nullable results,
                              NSError *_Nullable operationError) {
                     if (!completion) {
                         return;
                     }
                     if (operationError) {
                         completion(nil, operationError);
                     } else {
                         NSMutableArray<SKYRecord *> *records = [NSMutableArray array];
                         for (SKYRecordResult<SKYRecord *> *result in results) {
                             [records addObject:result.value];
                         }
                         completion(records, nil);
                     }
                 }];
}

- (void)deleteRecordsNonAtomically:(NSArray<SKYRecord *> *)records
                        completion:(void (^)(NSArray<SKYRecordResult<SKYRecord *> *> *_Nullable,
                                             NSError *_Nullable))completion
{
    [self sky_deleteRecords:records atomically:NO completion:completion];
}

#pragma mark - Querying Records

- (void)performQuery:(SKYQuery *)query
          completion:(void (^)(NSArray<SKYRecord *> *, SKYQueryInfo *, NSError *))completion
{
    SKYQueryOperation *operation = [[SKYQueryOperation alloc] initWithQuery:query];

    if (completion) {
        operation.queryRecordsCompletionBlock =
            ^(NSArray<SKYRecord *> *fetchedRecords, SKYQueryInfo *queryInfo,
              NSError *operationError) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    completion(fetchedRecords, queryInfo, operationError);
                });
            };
    }

    [self executeOperation:operation];
}

- (void)performCachedQuery:(SKYQuery *)query
                completion:(void (^)(NSArray<SKYRecord *> *, BOOL, NSError *))completion
{
    SKYQueryCache *cache = [[SKYQueryCache alloc] initWithDatabase:self];
    NSArray *cachedResults = [cache cachedResultsWithQuery:query];
    if (cachedResults && completion) {
        completion(cachedResults, YES, nil);
    }

    [self performQuery:query
            completion:^(NSArray<SKYRecord *> *results, SKYQueryInfo *info, NSError *error) {
                if (error) {
                    if (completion) {
                        completion(cachedResults, NO, error);
                    }
                } else {
                    [cache cacheQuery:query results:results];
                    if (completion) {
                        completion(results, NO, nil);
                    }
                }
            }];
}

#pragma mark - Upload Assets

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
        SKYAsset *asset, SKYAsset *newAsset, NSURL *postURL,
        NSDictionary<NSString *, NSObject *> *extraFields, NSError *operationError) {
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
                    if (postOperationError) {
                        completionHandler(asset, postOperationError);
                    } else {
                        // return the new asset generated by the server
                        // which updated file url
                        completionHandler(newAsset, nil);
                    }
                });
            }
        };

        [wself.container addOperation:postOperation];
    };

    [self.container addOperation:operation];
}

@end
