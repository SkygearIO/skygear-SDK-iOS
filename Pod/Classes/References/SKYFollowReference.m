//
//  SKYFollowReference.m
//  askq
//
//  Created by Kenji Pa on 22/1/15.
//  Copyright (c) 2015 Rocky Chan. All rights reserved.
//

#import "SKYFollowReference_Private.h"

#import "SKYFollowQuery.h"

NSString * const SKYFollowerReferenceFollowTypeDefault = @"_followings";

@implementation SKYFollowReference

- (instancetype)initWithUserRecordID:(SKYUserRecordID *)userRecordID {
    return [self initWithUserRecordID:userRecordID followType:SKYFollowerReferenceFollowTypeDefault];
}

- (instancetype)initWithUserRecordID:(SKYUserRecordID *)userRecordID followType:(NSString *)followType {
    self = [super init];
    if (self) {
        _userRecordID = userRecordID;
        _followType = followType;
    }
    return self;
}


- (SKYQuery *)followerQuery {
    return [[SKYFollowQuery alloc] initFollowerQueryWithUserRecordID:self.userRecordID];
}

- (SKYQuery *)followingQuery {
    return [[SKYFollowQuery alloc] initFollowingQueryWithUserRecordID:self.userRecordID];
}

- (SKYQuery *)mutualFollowerQuery {
    return [[SKYFollowQuery alloc] initMutualFollowerQueryWithUserRecordID:self.userRecordID];
}

@end
