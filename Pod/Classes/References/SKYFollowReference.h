//
//  SKYFollowReference.h
//  askq
//
//  Created by Kenji Pa on 22/1/15.
//  Copyright (c) 2015 Rocky Chan. All rights reserved.
//

#import "SKYReference.h"

#import "SKYQuery.h"
#import "SKYUser.h"
#import "SKYUserRecordID.h"

extern NSString *const SKYFollowerReferenceFollowTypeDefault;

@interface SKYFollowReference : SKYReference

- (instancetype)init NS_UNAVAILABLE;

// return a specially crafted SKYQuery that matches the following users
// of whose this follow reference is taken from
// the returned can then used to construct a SKYQueryOperation or ModifySubscriptionsOperation
- (SKYQuery *)followingQuery;

// similiar to -followingQuery, only with the difference
// that the returned SKYQuery only matches users that are the user's followers
- (SKYQuery *)followerQuery;

- (SKYQuery *)mutualFollowerQuery;

@property (nonatomic, readonly, copy) SKYUserRecordID *userRecordID;
@property (nonatomic, readonly, copy) NSString *followType;

- (void)add:(SKYUser *)user;
- (void)remove:(SKYUser *)user;

@end
