//
//  SKYFetchNewsfeedOperation.m
//  askq
//
//  Created by Kenji Pa on 23/1/15.
//  Copyright (c) 2015 Rocky Chan. All rights reserved.
//

#import "SKYFetchNewsfeedOperation.h"

#import "SKYContainer.h"

@implementation SKYFetchNewsfeedOperation

+ (instancetype)operationForCurrentUserWithNewsfeedID:(NSString *)newsfeedID {
    return [self operationWithNewsfeedID:newsfeedID userRecordID:[SKYContainer defaultContainer].currentUserRecordID];
}

+ (instancetype)operationWithNewsfeedID:(NSString *)newsfeedID
                           userRecordID:(SKYUserRecordID *)userRecordID {
    return [[self alloc] initWithNewsfeedID:newsfeedID userRecordID:userRecordID];
}

+ (instancetype)operationWithCursor:(SKYNewsfeedCursor *)cursor
{
    return [[self alloc] initWithCursor:cursor];
}

- (instancetype)initForCurrentUserWithNewsfeedID:(NSString *)newsfeedID {
    return [self initWithNewsfeedID:newsfeedID userRecordID:[SKYContainer defaultContainer].currentUserRecordID];
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

- (instancetype)initWithCursor:(SKYNewsfeedCursor *)cursor {
    self = [super init];
    if (self) {
        _cursor = cursor;
    }
    return self;
}

- (BOOL)isAsynchronous
{
    return NO;
}

- (void)main {
    NSAssert(self.userRecordID != nil, @"userRecordID cannot be nil");

    if (self.newsfeedItemFetchedBlock) {
        for (SKYNewsfeedItem *item in self.results) {
            self.newsfeedItemFetchedBlock(item);
        }
    }

    if (self.fetchCompletionBlock) {
        self.fetchCompletionBlock(nil, nil);
    }
}

@end
