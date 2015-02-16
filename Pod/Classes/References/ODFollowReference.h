//
//  ODFollowReference.h
//  askq
//
//  Created by Kenji Pa on 22/1/15.
//  Copyright (c) 2015 Rocky Chan. All rights reserved.
//

#import "ODReference.h"

#import "ODQuery.h"
#import "ODUser.h"
#import "ODUserRecordID.h"

extern NSString * const ODFollowerReferenceFollowTypeDefault;

@interface ODFollowReference : ODReference

- (instancetype)init NS_UNAVAILABLE;

// return a specially crafted ODQuery that matches the following users
// of whose this follow reference is taken from
// the returned can then used to construct a ODQueryOperation or ModifySubscriptionsOperation
- (ODQuery *)followingQuery;

// similiar to -followingQuery, only with the difference
// that the returned ODQuery only matches users that are the user's followers
- (ODQuery *)followerQuery;

- (ODQuery *)mutualFollowerQuery;

@property (nonatomic, readonly, copy) ODUserRecordID *userRecordID;
@property (nonatomic, readonly, copy) NSString *followType;

- (void)add:(ODUser *)user;
- (void)remove:(ODUser *)user;

@end
