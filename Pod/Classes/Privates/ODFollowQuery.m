//
//  ODFollowQuery.m
//  askq
//
//  Created by Kenji Pa on 1/2/15.
//  Copyright (c) 2015 Rocky Chan. All rights reserved.
//

#import "ODFollowQuery.h"

#import "ODRecord.h"

@implementation ODFollowQuery

- (instancetype)initFollowerQueryWithUserRecordID:(ODUserRecordID *)userRecordID {
    return [self initWithUserRecordID:userRecordID followQueryType:ODFollowQueryTypeFollower];
}

- (instancetype)initFollowingQueryWithUserRecordID:(ODUserRecordID *)userRecordID {
    return [self initWithUserRecordID:userRecordID followQueryType:ODFollowQueryTypeFollowing];
}

- (instancetype)initMutualFollowerQueryWithUserRecordID:(ODUserRecordID *)userRecordID {
    return [self initWithUserRecordID:userRecordID followQueryType:ODFollowQueryTypeMutual];
}

- (instancetype)initWithUserRecordID:(ODUserRecordID *)userRecordID followQueryType:(ODFollowQueryType)followQueryType {
    self = [super initWithRecordType:ODRecordTypeUserRecord predicate:nil];
    if (self) {
        _userRecordID = userRecordID;
        _followQueryType = followQueryType;
    }
    return self;
}

@end
