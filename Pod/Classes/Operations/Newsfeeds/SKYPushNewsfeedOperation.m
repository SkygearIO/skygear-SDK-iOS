//
//  SKYPushNewsfeedOperation.m
//  askq
//
//  Created by Kenji Pa on 23/1/15.
//  Copyright (c) 2015 Rocky Chan. All rights reserved.
//

#import "SKYPushNewsfeedOperation.h"

@implementation SKYPushNewsfeedOperation

- (instancetype)initWithNewsfeedItem:(SKYNewsfeedItem *)feedItem
                  pushingToReference:(SKYReference *)reference
                       forNewsfeedID:(NSString *)newsfeedID
{
    return [self initWithNewsfeedItems:@[ feedItem ]
                    pushingToReference:reference
                         forNewsfeedID:newsfeedID];
}

- (instancetype)initWithNewsfeedItems:(NSArray /* SKYNewsfeedItem */ *)feedItems
                   pushingToReference:(SKYReference *)reference
                        forNewsfeedID:(NSString *)newsfeedID
{
    self = [super init];
    if (self) {
        _newfeedItems = feedItems;
        _reference = reference;
        _newsfeedID = newsfeedID;
    }
    return self;
}

@end
