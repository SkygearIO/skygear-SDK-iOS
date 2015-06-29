//
//  ODDatabase.m
//  askq
//
//  Created by Kenji Pa on 19/1/15.
//  Copyright (c) 2015 Rocky Chan. All rights reserved.
//

#import "ODDatabase.h"

#import "ODDatabaseOperation.h"
#import "ODRecord_Private.h"
#import "ODRecordID.h"
#import "ODFetchRecordsOperation.h"
#import "ODModifyRecordsOperation.h"
#import "ODModifySubscriptionsOperation.h"
#import "ODDeleteRecordsOperation.h"
#import "ODQueryOperation.h"
#import "ODQueryCache.h"

@interface ODDatabase()

@property (nonatomic, readonly) NSMutableArray /* ODDatabaseOperation */ *pendingOperations;
@property (nonatomic, readonly) NSOperationQueue *operationQueue;
@property (nonatomic, strong, readwrite) ODContainer *container;

@end

@implementation ODDatabase

- (instancetype)initWithContainer:(ODContainer *)container {
    self = [super init];
    if (self) {
        _container = container;
        _pendingOperations = [NSMutableArray array];
        _databaseID = @"_public";
        _operationQueue = [[NSOperationQueue alloc] init];
        _operationQueue.name = @"ODDatabaseQueue";
    }
    return self;
}

- (void)addOperation:(ODDatabaseOperation *)operation {
    [self.pendingOperations addObject:operation];
}

- (void)executeOperation:(ODDatabaseOperation *)operation {
    operation.database = self;
    operation.container = self.container;
    [self.operationQueue addOperation:operation];
}

- (void)commit {
    [self.operationQueue addOperations:self.pendingOperations waitUntilFinished:NO];
    [self.pendingOperations removeAllObjects];
}

- (ODUser *)currentUser {
    ODUserRecordID *currentUserRecordID = [self.container currentUserRecordID];
    return currentUserRecordID ? [[ODUser alloc] initWithUserRecordID:currentUserRecordID] : nil;
}

- (void)saveSubscription:(ODSubscription *)subscription
       completionHandler:(void (^)(ODSubscription *subscription,
                                   NSError *error))completionHandler {
    ODModifySubscriptionsOperation *operation = [[ODModifySubscriptionsOperation alloc] initWithSubscriptionsToSave:@[subscription]];
    if (completionHandler) {
        operation.modifySubscriptionsCompletionBlock = ^(NSArray *savedSubscriptions, NSError *operationError) {
            dispatch_async(dispatch_get_main_queue(), ^{
                ODSubscription *subscription = nil;
                if (!operationError) {
                    subscription = savedSubscriptions[0];
                }

                completionHandler(subscription, operationError);
            });
        };
    }

    [self executeOperation:operation];
}

#pragma mark - Convenient methods for record operations

- (void)od_prepareRecordForSaving:(ODRecord *)record
{
    if (![record isKindOfClass:[ODRecord class]]) {
        NSString *reason = [NSString stringWithFormat:@"The given object %@ is not an ODRecord.", record];
        @throw [NSException exceptionWithName:NSInvalidArgumentException
                                       reason:reason
                                     userInfo:nil];
    }
    
    if (!record.creationDate) {
        record.creationDate = [NSDate date];
    }
}

- (void)saveRecord:(ODRecord *)record completion:(ODRecordSaveCompletion)completion {
    if ([record.recordType isEqualToString:@"question"]) {
        record[@"id"] = @6666;
        record.recordID = [[ODRecordID alloc] initWithRecordType:@"question" name:@"6666"];
    }
    [self od_prepareRecordForSaving:record];
    
    ODModifyRecordsOperation *operation = [[ODModifyRecordsOperation alloc] initWithRecordsToSave:@[record]];
    
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

- (void)saveRecords:(NSArray *)records completionHandler:(void (^)(NSArray *, NSError *))completionHandler perRecordErrorHandler:(void (^)(ODRecord *, NSError *))errorHandler
{
    [records enumerateObjectsUsingBlock:^(ODRecord *obj, NSUInteger idx, BOOL *stop) {
        [self od_prepareRecordForSaving:obj];
    }];
    
    ODModifyRecordsOperation *operation = [[ODModifyRecordsOperation alloc] initWithRecordsToSave:records];
    
    if (completionHandler) {
        operation.modifyRecordsCompletionBlock = ^(NSArray *savedRecords, NSError *operationError) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completionHandler(savedRecords, operationError);
            });
        };
    }
    
    if (errorHandler) {
        operation.perRecordCompletionBlock = ^(ODRecord *record, NSError *error) {
            if (error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    errorHandler(record, error);
                });
            }
        };
    }
    
    [self executeOperation:operation];
}

- (void)fetchRecordWithID:(ODRecordID *)recordID
        completionHandler:(void (^)(ODRecord *record,
                                    NSError *error))completionHandler {
    ODFetchRecordsOperation *operation = [[ODFetchRecordsOperation alloc] initWithRecordIDs:@[recordID]];

    if (completionHandler) {
        operation.fetchRecordsCompletionBlock = ^(NSDictionary *recordsByRecordID, NSError *operationError) {
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

- (void)fetchRecordsWithIDs:(NSArray *)recordIDs completionHandler:(void (^)(NSDictionary *, NSError *))completionHandler perRecordErrorHandler:(void (^)(ODRecordID *, NSError *))errorHandler
{
    ODFetchRecordsOperation *operation = [[ODFetchRecordsOperation alloc] initWithRecordIDs:recordIDs];
    
    if (completionHandler) {
        operation.fetchRecordsCompletionBlock = ^(NSDictionary *recordsByRecordID, NSError *operationError) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completionHandler(recordsByRecordID, operationError);
            });
        };
    }
    
    if (errorHandler) {
        operation.perRecordCompletionBlock = ^(ODRecord *record, ODRecordID *recordID, NSError *error) {
            if (error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    errorHandler(recordID, error);
                    
                });
            }
        };
    }
    
    [self executeOperation:operation];
}

- (void)deleteRecordWithID:(ODRecordID *)recordID
         completionHandler:(void (^)(ODRecordID *recordID,
                                     NSError *error))completionHandler
{
    ODDeleteRecordsOperation *operation = [[ODDeleteRecordsOperation alloc] initWithRecordIDsToDelete:@[recordID]];
    
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

- (void)deleteRecordsWithIDs:(NSArray *)recordIDs completionHandler:(void (^)(NSArray *, NSError *))completionHandler perRecordErrorHandler:(void (^)(ODRecordID *, NSError *))errorHandler
{
    ODDeleteRecordsOperation *operation = [[ODDeleteRecordsOperation alloc] initWithRecordIDsToDelete:recordIDs];
    
    if (completionHandler) {
        operation.deleteRecordsCompletionBlock = ^(NSArray *recordIDs, NSError *operationError) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completionHandler(recordIDs, operationError);
            });
        };
    }
    
    if (errorHandler) {
        operation.perRecordCompletionBlock = ^(ODRecordID *deletedRecordID, NSError *error) {
            if (error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    errorHandler(deletedRecordID, error);
                });
            }
        };
    }
    
    [self executeOperation:operation];
}

- (void)performQuery:(ODQuery *)query completionHandler:(void (^)(NSArray *, NSError *))completionHandler
{
    ODQueryOperation *operation = [[ODQueryOperation alloc] initWithQuery:query];
    
    if (completionHandler) {
        operation.queryRecordsCompletionBlock = ^(NSArray *fetchedRecords, ODQueryCursor *cursor, NSError *operationError) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completionHandler(fetchedRecords, operationError);
            });
        };
    }
    
    [self executeOperation:operation];
}

- (void)performCachedQuery:(ODQuery *)query completionHandler:(void (^)(NSArray *, BOOL, NSError *))completionHandler
{
    ODQueryCache *cache = [[ODQueryCache alloc] initWithDatabase:self];
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
