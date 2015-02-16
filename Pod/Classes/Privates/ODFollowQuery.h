//
//  ODFollowQuery.h
//  askq
//
//  Created by Kenji Pa on 1/2/15.
//  Copyright (c) 2015 Rocky Chan. All rights reserved.
//

#import "ODQuery.h"

#import "ODUserRecordID.h"

typedef enum : NSInteger {
    ODFollowQueryTypeFollower = 1,
    ODFollowQueryTypeFollowing = 2,
    ODFollowQueryTypeMutual = 3,
} ODFollowQueryType;

// private class of ODQuery to be return on FollowReference-followerQuery
// and FollowReference-followingQuery
@interface ODFollowQuery : ODQuery

- (instancetype)initWithRecordType:(NSString *)recordType predicate:(NSPredicate *)predicate NS_UNAVAILABLE;

- (instancetype)initFollowerQueryWithUserRecordID:(ODUserRecordID *)userRecordID;
- (instancetype)initFollowingQueryWithUserRecordID:(ODUserRecordID *)userRecordID;
- (instancetype)initMutualFollowerQueryWithUserRecordID:(ODUserRecordID *)userRecordID;
- (instancetype)initWithUserRecordID:(ODUserRecordID *)userRecordID followQueryType:(ODFollowQueryType)followQueryType NS_DESIGNATED_INITIALIZER;

@property (nonatomic, readonly, assign) ODFollowQueryType followQueryType;
@property (nonatomic, readonly) ODUserRecordID* userRecordID;

@end
