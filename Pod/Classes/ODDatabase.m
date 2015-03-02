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
#import "ODDeleteRecordsOperation.h"
#import "ODQueryOperation.h"

@interface ODDatabase()

@property (nonatomic, readonly) NSMutableArray /* ODDatabaseOperation */ *pendingOperations;
@property (nonatomic, readonly) NSOperationQueue *operationQueue;

@end

@implementation ODDatabase

- (instancetype)initPrivately {
    self = [super init];
    if (self) {
        _pendingOperations = [NSMutableArray array];

        _operationQueue = [[NSOperationQueue alloc] init];
        _operationQueue.name = @"ODDatabaseQueue";
    }
    return self;
}

- (NSString *)databaseID
{
    return @"DATABASE_ID";
}

- (void)addOperation:(ODDatabaseOperation *)operation {
    [self.pendingOperations addObject:operation];
}

- (void)executeOperation:(ODDatabaseOperation *)operation {
    [self.operationQueue addOperation:operation];
}

- (void)commit {
    [self.operationQueue addOperations:self.pendingOperations waitUntilFinished:NO];
    [self.pendingOperations removeAllObjects];
}

- (ODUser *)currentUser {
    return [[ODUser alloc] initWithUserRecordID:[[ODContainer defaultContainer] currentUserRecordID]];
}

- (void)saveSubscription:(ODSubscription *)subscription
       completionHandler:(void (^)(ODSubscription *subscription,
                                   NSError *error))completionHandler {
    if (completionHandler) {
        completionHandler(subscription, nil);
    }
}

- (void)saveRecord:(ODRecord *)record completion:(ODRecordSaveCompletion)completion {
    if ([record.recordType isEqualToString:@"question"]) {
        record[@"id"] = @6666;
        record.recordID = [[ODRecordID alloc] initWithRecordName:@"6666"];
    }
    record.creationDate = [NSDate date];
    
    ODModifyRecordsOperation *operation = [[ODModifyRecordsOperation alloc] initWithRecordsToSave:@[record]];
    operation.container = [ODContainer defaultContainer];
    operation.database = self;
    
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
    
    [[NSOperationQueue mainQueue] addOperation:operation];
}

- (void)fetchRecordWithID:(ODRecordID *)recordID
        completionHandler:(void (^)(ODRecord *record,
                                    NSError *error))completionHandler {
    ODFetchRecordsOperation *operation = [[ODFetchRecordsOperation alloc] initWithRecordIDs:@[recordID]];
    operation.container = [ODContainer defaultContainer];
    operation.database = self;

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
    
    [[NSOperationQueue mainQueue] addOperation:operation];
}

- (void)deleteRecordWithID:(ODRecordID *)recordID
         completionHandler:(void (^)(ODRecordID *recordID,
                                     NSError *error))completionHandler
{
    ODDeleteRecordsOperation *operation = [[ODDeleteRecordsOperation alloc] initWithRecordIDsToDelete:@[recordID]];
    operation.container = [ODContainer defaultContainer];
    operation.database = self;
    
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
    
    [[NSOperationQueue mainQueue] addOperation:operation];
}

- (void)performQuery:(ODQuery *)query inZoneWithID:(ODRecordZoneID *)zoneID completionHandler:(void (^)(NSArray *, NSError *))completionHandler
{
    ODQueryOperation *operation = [[ODQueryOperation alloc] initWithQuery:query];
    operation.container = [ODContainer defaultContainer];
    operation.database = self;
    
    if (completionHandler) {
        operation.queryRecordsCompletionBlock = ^(NSArray *fetchedRecords, ODQueryCursor *cursor, NSError *operationError) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completionHandler(fetchedRecords, operationError);
            });
        };
    }
    
    [self addOperation:operation];
    [self commit];
}

@end
