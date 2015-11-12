//
//  SKYFollowQuery.h
//  askq
//
//  Created by Kenji Pa on 1/2/15.
//  Copyright (c) 2015 Rocky Chan. All rights reserved.
//

#import "SKYQuery.h"

#import "SKYUserRecordID.h"

typedef enum : NSInteger {
    SKYFollowQueryTypeFollower = 1,
    SKYFollowQueryTypeFollowing = 2,
    SKYFollowQueryTypeMutual = 3,
} SKYFollowQueryType;

// private class of SKYQuery to be return on FollowReference-followerQuery
// and FollowReference-followingQuery
@interface SKYFollowQuery : SKYQuery

- (instancetype)initWithRecordType:(NSString *)recordType
                         predicate:(NSPredicate *)predicate NS_UNAVAILABLE;

- (instancetype)initFollowerQueryWithUserRecordID:(SKYUserRecordID *)userRecordID;
- (instancetype)initFollowingQueryWithUserRecordID:(SKYUserRecordID *)userRecordID;
- (instancetype)initMutualFollowerQueryWithUserRecordID:(SKYUserRecordID *)userRecordID;
- (instancetype)initWithUserRecordID:(SKYUserRecordID *)userRecordID
                     followQueryType:(SKYFollowQueryType)followQueryType NS_DESIGNATED_INITIALIZER;

@property (nonatomic, readonly, assign) SKYFollowQueryType followQueryType;
@property (nonatomic, readonly) SKYUserRecordID *userRecordID;

@end
