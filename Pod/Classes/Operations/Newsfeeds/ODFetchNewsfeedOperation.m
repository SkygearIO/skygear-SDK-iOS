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

+ (instancetype)operationForCurrentUserWithNewsfeedID:(NSString *)newsfeedID {
    return [self operationWithNewsfeedID:newsfeedID userRecordID:[ODContainer defaultContainer].currentUserRecordID];
}

+ (instancetype)operationWithNewsfeedID:(NSString *)newsfeedID
                           userRecordID:(ODUserRecordID *)userRecordID {
    return [[self.class alloc] initWithNewsfeedID:newsfeedID userRecordID:userRecordID];
}

- (instancetype)initForCurrentUserWithNewsfeedID:(NSString *)newsfeedID {
    return [self initWithNewsfeedID:newsfeedID userRecordID:[ODContainer defaultContainer].currentUserRecordID];
}

- (instancetype)initWithNewsfeedID:(NSString *)newsfeedID
                      userRecordID:userRecordID {
    self = [super init];
    if (self) {
        _newsfeedID = newsfeedID;
        _userRecordID = userRecordID;
    }
    return self;
}

- (instancetype)initWithCursor:(ODNewsfeedCursor *)cursor {
    self = [super init];
    if (self) {
        _cursor = cursor;
    }
    return self;
}

- (void)main {
    NSAssert(self.userRecordID != nil, @"userRecordID cannot be nil");

    if (self.newsfeedItemFetchedBlock) {
        for (ODNewsfeedItem *item in self.results) {
            self.newsfeedItemFetchedBlock(item);
        }
    }

    if (self.fetchCompletionBlock) {
        self.fetchCompletionBlock(nil, nil);
    }
}

@end
