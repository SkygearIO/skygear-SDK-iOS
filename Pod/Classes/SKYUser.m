//
//  SKYUser.m
//  askq
//
//  Created by Kenji Pa on 27/1/15.
//  Copyright (c) 2015 Rocky Chan. All rights reserved.
//

#import "SKYUser.h"

#import "SKYFollowReference_Private.h"
#import "SKYQueryOperation.h"

@interface SKYUser()

@property (nonatomic, readwrite, copy) SKYUserRecordID *recordID;

@end

@implementation SKYUser

- (instancetype)initWithUserRecordID:(SKYUserRecordID *)recordID {
    return [self initWithUserRecordID:recordID data:nil];
}

- (instancetype)initWithUserRecordID:(SKYUserRecordID *)recordID data:(NSDictionary *)data {
    self = [super initWithRecordID:recordID data:data];
    return self;
}

+ (instancetype)userWithUserRecordID:(SKYUserRecordID *)recordID
{
    return [[self alloc] initWithUserRecordID:recordID];
}

+ (instancetype)userWithUserRecordID:(SKYUserRecordID *)recordID data:(NSDictionary *)data
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

- (SKYUserRecordID *)recordID {
    return (SKYUserRecordID *)[super recordID];
}

- (SKYFollowReference *)followReference {
    return [[SKYFollowReference alloc] initWithUserRecordID:self.recordID];
}

- (SKYQueryOperation *)mutualFollowerQueryOperation {
    return [self mutualFollowerQueryOperationWithRecordFetchedBlock:nil queryCompletionBlock:nil];
}

- (SKYQueryOperation *)mutualFollowerQueryOperationWithRecordFetchedBlock:(void(^)(SKYRecord *record))recordFetchedBlock
                                                    queryCompletionBlock:(void(^)(SKYQueryCursor *cursor, NSError *operationError))queryCompletionBlock {
    SKYQuery *mutualFollowerQuery = self.followReference.mutualFollowerQuery;
    SKYQueryOperation *queryOperation = [[SKYQueryOperation alloc] initWithQuery:mutualFollowerQuery];
    queryOperation.perRecordCompletionBlock = recordFetchedBlock;
    queryOperation.queryRecordsCompletionBlock = ^(NSArray *fetchedRecords, SKYQueryCursor *cursor, NSError *operationError) {
        if (queryCompletionBlock) {
            queryCompletionBlock(cursor, operationError);
        }
    };

    return queryOperation;
}

- (SKYQueryOperation *)followerQueryOperation {
    return [self followerQueryOperationWithRecordFetchedBlock:nil queryCompletionBlock:nil];
}

- (SKYQueryOperation *)followerQueryOperationWithRecordFetchedBlock:(void(^)(SKYRecord *record))recordFetchedBlock
                                              queryCompletionBlock:(void(^)(SKYQueryCursor *cursor, NSError *operationError))queryCompletionBlock {
    SKYQuery *followerQuery = self.followReference.followerQuery;
    SKYQueryOperation *queryOperation = [[SKYQueryOperation alloc] initWithQuery:followerQuery];
    queryOperation.perRecordCompletionBlock = recordFetchedBlock;
    queryOperation.queryRecordsCompletionBlock = ^(NSArray *fetchedRecords, SKYQueryCursor *cursor, NSError *operationError) {
        if (queryCompletionBlock) {
            queryCompletionBlock(cursor, operationError);
        }
    };

    return queryOperation;
}

@end
