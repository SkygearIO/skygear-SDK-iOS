//
//  ODUser.m
//  askq
//
//  Created by Kenji Pa on 27/1/15.
//  Copyright (c) 2015 Rocky Chan. All rights reserved.
//

#import "ODUser.h"

#import "ODFollowReference_Private.h"
#import "ODQueryOperation.h"

@interface ODUser()

@property (nonatomic, readwrite, copy) ODUserRecordID *recordID;

@end

@implementation ODUser

- (instancetype)initWithUserRecordID:(ODUserRecordID *)recordID {
    return [self initWithUserRecordID:recordID data:nil];
}

- (instancetype)initWithUserRecordID:(ODUserRecordID *)recordID data:(NSDictionary *)data {
    self = [super initWithRecordID:recordID data:data];
    return self;
}

+ (instancetype)userWithUserRecordID:(ODUserRecordID *)recordID
{
    return [[self alloc] initWithUserRecordID:recordID];
}

+ (instancetype)userWithUserRecordID:(ODUserRecordID *)recordID data:(NSDictionary *)data
{
    return [[self alloc] initWithUserRecordID:recordID data:data];
}

- (NSString *)username {
    return self.recordID.username;
}

- (NSString *)email {
    return self.recordID.email;
}

- (NSDictionary *)authData {
    return self.recordID.authData;
}

- (ODUserRecordID *)recordID {
    return (ODUserRecordID *)[super recordID];
}

- (ODFollowReference *)followReference {
    return [[ODFollowReference alloc] initWithUserRecordID:self.recordID];
}

- (ODQueryOperation *)mutualFollowerQueryOperation {
    return [self mutualFollowerQueryOperationWithRecordFetchedBlock:nil queryCompletionBlock:nil];
}

- (ODQueryOperation *)mutualFollowerQueryOperationWithRecordFetchedBlock:(void(^)(ODRecord *record))recordFetchedBlock
                                                    queryCompletionBlock:(void(^)(ODQueryCursor *cursor, NSError *operationError))queryCompletionBlock {
    ODQuery *mutualFollowerQuery = self.followReference.mutualFollowerQuery;
    ODQueryOperation *queryOperation = [[ODQueryOperation alloc] initWithQuery:mutualFollowerQuery];
    queryOperation.perRecordCompletionBlock = recordFetchedBlock;
    queryOperation.queryRecordsCompletionBlock = ^(NSArray *fetchedRecords, ODQueryCursor *cursor, NSError *operationError) {
        if (queryCompletionBlock) {
            queryCompletionBlock(cursor, operationError);
        }
    };

    return queryOperation;
}

- (ODQueryOperation *)followerQueryOperation {
    return [self followerQueryOperationWithRecordFetchedBlock:nil queryCompletionBlock:nil];
}

- (ODQueryOperation *)followerQueryOperationWithRecordFetchedBlock:(void(^)(ODRecord *record))recordFetchedBlock
                                              queryCompletionBlock:(void(^)(ODQueryCursor *cursor, NSError *operationError))queryCompletionBlock {
    ODQuery *followerQuery = self.followReference.followerQuery;
    ODQueryOperation *queryOperation = [[ODQueryOperation alloc] initWithQuery:followerQuery];
    queryOperation.perRecordCompletionBlock = recordFetchedBlock;
    queryOperation.queryRecordsCompletionBlock = ^(NSArray *fetchedRecords, ODQueryCursor *cursor, NSError *operationError) {
        if (queryCompletionBlock) {
            queryCompletionBlock(cursor, operationError);
        }
    };

    return queryOperation;
}

@end
