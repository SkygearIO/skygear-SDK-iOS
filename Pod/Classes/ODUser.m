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

@implementation ODUser

- (instancetype)initWithRecordType:(NSString *)recordType {
    NSAssert([recordType isEqualToString:ODRecordTypeUserRecord], @"Cannot init a ODUser with RecordType !=  ODRecordTypeUserRecord");
    return [super initWithRecordType:recordType];
}

- (instancetype)initWithRecordType:(NSString *)recordType recordID:(ODRecordID *)recordId {
    NSAssert([recordType isEqualToString:ODRecordTypeUserRecord], @"Cannot init a ODUser with RecordType !=  ODRecordTypeUserRecord");
    return [super initWithRecordType:recordType recordID:recordId];
}

- (instancetype)initWithUserRecordID:(ODUserRecordID *)recordID {
    self = [super initWithRecordType:ODRecordTypeUserRecord recordID:recordID];
    return self;
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
    queryOperation.recordFetchedBlock = recordFetchedBlock;
    queryOperation.queryCompletionBlock = queryCompletionBlock;

    return queryOperation;
}

- (ODQueryOperation *)followerQueryOperation {
    ODQueryOperation *operation = [self followerQueryOperationWithRecordFetchedBlock:nil queryCompletionBlock:nil];
}

- (ODQueryOperation *)followerQueryOperationWithRecordFetchedBlock:(void(^)(ODRecord *record))recordFetchedBlock
                                              queryCompletionBlock:(void(^)(ODQueryCursor *cursor, NSError *operationError))queryCompletionBlock {
    ODQuery *followerQuery = self.followReference.followerQuery;
    ODQueryOperation *queryOperation = [[ODQueryOperation alloc] initWithQuery:followerQuery];
    queryOperation.recordFetchedBlock = recordFetchedBlock;
    queryOperation.queryCompletionBlock = queryCompletionBlock;

    return queryOperation;
}

@end
