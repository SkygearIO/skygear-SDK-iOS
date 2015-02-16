//
//  ODFetchNewsfeedOperation.m
//  askq
//
//  Created by Kenji Pa on 23/1/15.
//  Copyright (c) 2015 Rocky Chan. All rights reserved.
//

#import "ODFetchNewsfeedOperation.h"

#import "ODContainer.h"

@implementation ODFetchNewsfeedOperation

- (instancetype)initForCurrentUserWithNewsFeed:(ODNewsfeed *)newsfeed {
    return [self initWithNewsFeed:newsfeed forUserRecordID:[ODContainer defaultContainer].currentUserRecordID];
}

- (instancetype)initWithNewsFeed:(ODNewsfeed *)newsfeed
                 forUserRecordID:userRecordID {
    self = [super init];
    if (self) {
        _newsfeed = newsfeed;
        _userRecordID = userRecordID;
    }
    return self;
}

@end
