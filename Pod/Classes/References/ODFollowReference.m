//
//  ODFollowReference.m
//  askq
//
//  Created by Kenji Pa on 22/1/15.
//  Copyright (c) 2015 Rocky Chan. All rights reserved.
//

#import "ODFollowReference_Private.h"

#import "ODFollowQuery.h"

NSString * const ODFollowerReferenceFollowTypeDefault = @"_followings";

@implementation ODFollowReference

- (instancetype)initWithUserRecordID:(ODUserRecordID *)userRecordID {
    return [self initWithUserRecordID:userRecordID followType:ODFollowerReferenceFollowTypeDefault];
}

- (instancetype)initWithUserRecordID:(ODUserRecordID *)userRecordID followType:(NSString *)followType {
    self = [super init];
    if (self) {
        _userRecordID = userRecordID;
        _followType = followType;
    }
    return self;
}


- (ODQuery *)followerQuery {
    return [[ODFollowQuery alloc] initFollowerQueryWithUserRecordID:self.userRecordID];
}

- (ODQuery *)followingQuery {
    return [[ODFollowQuery alloc] initFollowingQueryWithUserRecordID:self.userRecordID];
}

- (ODQuery *)mutualFollowerQuery {
    return [[ODFollowQuery alloc] initMutualFollowerQueryWithUserRecordID:self.userRecordID];
}

@end
