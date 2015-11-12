//
//  SKYDatabase.m
//  askq
//
//  Created by Kenji Pa on 19/1/15.
//  Copyright (c) 2015 Rocky Chan. All rights reserved.
//

#import "SKYDatabase.h"

#import "SKYDatabaseOperation.h"
#import "SKYDeleteRecordsOperation.h"
#import "SKYDeleteSubscriptionsOperation.h"
#import "SKYFetchRecordsOperation.h"
#import "SKYModifyRecordsOperation.h"
#import "SKYModifySubscriptionsOperation.h"
#import "SKYQueryOperation.h"
#import "SKYQueryCache.h"
#import "SKYRecord_Private.h"
#import "SKYRecordID.h"

@interface SKYDatabase ()

@property (nonatomic, readonly) NSMutableArray /* SKYDatabaseOperation */ *pendingOperations;
@property (nonatomic, readonly) NSOperationQueue *operationQueue;
@property (nonatomic, strong, readwrite) SKYContainer *container;

@end

@implementation SKYDatabase

- (instancetype)initWithContainer:(SKYContainer *)container
{
    self = [super init];
    if (self) {
        _container = container;
        _pendingOperations = [NSMutableArray array];
        _databaseID = @"_public";
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

- (SKYUser *)currentUser
{
    SKYUserRecordID *currentUserRecordID = [self.container currentUserRecordID];
    return currentUserRecordID ? [[SKYUser alloc] initWithUserRecordID:currentUserRecordID] : nil;
}

- (void)saveSubscription:(SKYSubscription *)subscription
       completionHandler:(void (^)(SKYSubscription *subscription, NSError *error))completionHandler
{
    SKYModifySubscriptionsOperation *operation =
        [[SKYModifySubscriptionsOperation alloc] initWithSubscriptionsToSave:@[ subscription ]];
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
    SKYDeleteSubscriptionsOperation *operation = [[SKYDeleteSubscriptionsOperation alloc]
        initWithSubscriptionIDsToDelete:@[ subscriptionID ]];
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

- (void)od_prepareRecordForSaving:(SKYRecord *)record
{
    if (![record isKindOfClass:[SKYRecord class]]) {
        NSString *reason =
            [NSString stringWithFormat:@"The given object %@ is not an SKYRecord.", record];
        @throw
            [NSException exceptionWithName:NSInvalidArgumentException reason:reason userInfo:nil];
    }

    if (!record.creationDate) {
        record.creationDate = [NSDate date];
    }
}

- (void)saveRecord:(SKYRecord *)record completion:(SKYRecordSaveCompletion)completion
{
    if ([record.recordType isEqualToString:@"question"]) {
        record[@"id"] = @6666;
        record.recordID = [[SKYRecordID alloc] initWithRecordType:@"question" name:@"6666"];
    }
    [self od_prepareRecordForSaving:record];

    SKYModifyRecordsOperation *operation =
        [[SKYModifyRecordsOperation alloc] initWithRecordsToSave:@[ record ]];

    if (completion) {
        operation.modifyRecordsCompletionBlock = ^(NSArray *savedRecords, NSError *operationError) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([savedRecords count] > 0) {
                    completion(savedRecords[0], operationError);
                } else {
                    completion(nil, operationError);
                }
            });
        };
    }

    [self executeOperation:operation];
}

- (void)saveRecords:(NSArray *)records
        completionHandler:(void (^)(NSArray *, NSError *))completionHandler
    perRecordErrorHandler:(void (^)(SKYRecord *, NSError *))errorHandler
{
    [records enumerateObjectsUsingBlock:^(SKYRecord *obj, NSUInteger idx, BOOL *stop) {
        [self od_prepareRecordForSaving:obj];
    }];

    SKYModifyRecordsOperation *operation =
        [[SKYModifyRecordsOperation alloc] initWithRecordsToSave:records];

    if (completionHandler) {
        operation.modifyRecordsCompletionBlock = ^(NSArray *savedRecords, NSError *operationError) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completionHandler(savedRecords, operationError);
            });
        };
    }

    if (errorHandler) {
        operation.perRecordCompletionBlock = ^(SKYRecord *record, NSError *error) {
            if (error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    errorHandler(record, error);
                });
            }
        };
    }

    [self executeOperation:operation];
}

- (void)saveRecordsAtomically:(NSArray *)records
            completionHandler:
                (void (^)(NSArray *savedRecords, NSError *operationError))completionHandler
{
    [records enumerateObjectsUsingBlock:^(SKYRecord *obj, NSUInteger idx, BOOL *stop) {
        [self od_prepareRecordForSaving:obj];
    }];

    SKYModifyRecordsOperation *operation =
        [[SKYModifyRecordsOperation alloc] initWithRecordsToSave:records];
    operation.atomic = YES;

    if (completionHandler) {
        operation.modifyRecordsCompletionBlock = ^(NSArray *savedRecords, NSError *operationError) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completionHandler(savedRecords, operationError);
            });
        };
    }

    [self executeOperation:operation];
}

- (void)fetchRecordWithID:(SKYRecordID *)recordID
        completionHandler:(void (^)(SKYRecord *record, NSError *error))completionHandler
{
    SKYFetchRecordsOperation *operation =
        [[SKYFetchRecordsOperation alloc] initWithRecordIDs:@[ recordID ]];

    if (completionHandler) {
        operation.fetchRecordsCompletionBlock =
            ^(NSDictionary *recordsByRecordID, NSError *operationError) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if ([recordsByRecordID count] > 0) {
                        completionHandler(recordsByRecordID[recordID], operationError);
                    } else {
                        completionHandler(nil, operationError);
                    }
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
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([recordIDs count] > 0) {
                    completionHandler(recordIDs[0], operationError);
                } else {
                    completionHandler(nil, operationError);
                }
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

@end
