//
//  SKYFollowQuery.m
//  askq
//
//  Created by Kenji Pa on 1/2/15.
//  Copyright (c) 2015 Rocky Chan. All rights reserved.
//

#import "SKYFollowQuery.h"

#import "SKYRecord.h"

@implementation SKYFollowQuery

- (instancetype)initFollowerQueryWithUserRecordID:(SKYUserRecordID *)userRecordID {
    return [self initWithUserRecordID:userRecordID followQueryType:SKYFollowQueryTypeFollower];
}

- (instancetype)initFollowingQueryWithUserRecordID:(SKYUserRecordID *)userRecordID {
    return [self initWithUserRecordID:userRecordID followQueryType:SKYFollowQueryTypeFollowing];
}

- (instancetype)initMutualFollowerQueryWithUserRecordID:(SKYUserRecordID *)userRecordID {
    return [self initWithUserRecordID:userRecordID followQueryType:SKYFollowQueryTypeMutual];
}

- (instancetype)initWithUserRecordID:(SKYUserRecordID *)userRecordID followQueryType:(SKYFollowQueryType)followQueryType {
    self = [super initWithRecordType:SKYRecordTypeUserRecord predicate:nil];
    if (self) {
        _userRecordID = userRecordID;
        _followQueryType = followQueryType;
    }
    return self;
}

@end
