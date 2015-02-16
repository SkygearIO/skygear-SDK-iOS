//
//  ODPushNewsfeedOperation.m
//  askq
//
//  Created by Kenji Pa on 23/1/15.
//  Copyright (c) 2015 Rocky Chan. All rights reserved.
//

#import "ODPushNewsfeedOperation.h"

@implementation ODPushNewsfeedOperation

- (instancetype)initWithNewsfeedItem:(ODNewsfeedItem *)feedItem
                  pushingToReference:(ODReference *)reference
                       forNewsfeedID:(NSString *)newsfeedID {
    return [self initWithNewsfeedItems:@[feedItem]
                    pushingToReference:reference
                         forNewsfeedID:newsfeedID];
}

- (instancetype)initWithNewsfeedItems:(NSArray /* ODNewsfeedItem */ *)feedItems
                   pushingToReference:(ODReference *)reference
                        forNewsfeedID:(NSString *)newsfeedID {
    self = [super init];
    if (self) {
        _newfeedItems = feedItems;
        _reference = reference;
        _newsfeedID = newsfeedID;
    }
    return self;
}

@end
