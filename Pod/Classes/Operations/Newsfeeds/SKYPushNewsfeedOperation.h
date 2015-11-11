//
//  SKYPushNewsfeedOperation.h
//  askq
//
//  Created by Kenji Pa on 23/1/15.
//  Copyright (c) 2015 Rocky Chan. All rights reserved.
//

#import "SKYDatabaseOperation.h"

#import "SKYNewsfeedItem.h"
#import "SKYReference.h"
#import "SKYRecord.h"

@interface SKYPushNewsfeedOperation : SKYDatabaseOperation

- (instancetype)initWithNewsfeedItem:(SKYNewsfeedItem *)newsfeedItem
                  pushingToReference:(SKYReference *)reference
                       forNewsfeedID:(NSString *)newsfeedID;

// is it really useful to push multiple items?
- (instancetype)initWithNewsfeedItems:(NSArray /* SKYNewsfeedItem */ *)newsfeedItems
                   pushingToReference:(SKYReference *)reference
                        forNewsfeedID:(NSString *)newsfeedID;

// seems pushing to a SKYQuery is also desirable?

@property (strong, nonatomic) NSString *newsfeedID;
@property (nonatomic, copy) NSArray /* SKYNewsfeedItem */ *newfeedItems;
// reference to push to
@property (nonatomic, copy) SKYReference *reference;

@property (nonatomic, copy) void (^pushNewsfeedCompletionBlock)
    (NSArray /* SKYNewsfeedItem */ *newsfeedItems, NSError *error);

@end
