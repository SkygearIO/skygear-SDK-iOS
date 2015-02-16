//
//  ODPushNewsfeedOperation.h
//  askq
//
//  Created by Kenji Pa on 23/1/15.
//  Copyright (c) 2015 Rocky Chan. All rights reserved.
//

#import "ODDatabaseOperation.h"

#import "ODNewsfeedItem.h"
#import "ODReference.h"
#import "ODRecord.h"

@interface ODPushNewsfeedOperation : ODDatabaseOperation

- (instancetype)initWithNewsfeedItem:(ODNewsfeedItem *)newsfeedItem
                  pushingToReference:(ODReference *)reference
                       forNewsfeedID:(NSString *)newsfeedID;

// is it really useful to push multiple items?
- (instancetype)initWithNewsfeedItems:(NSArray /* ODNewsfeedItem */ *)newsfeedItems
                   pushingToReference:(ODReference *)reference
                        forNewsfeedID:(NSString *)newsfeedID;

// seems pushing to a ODQuery is also desirable?

@property (strong, nonatomic) NSString *newsfeedID;
@property (nonatomic, copy) NSArray /* ODNewsfeedItem */ *newfeedItems;
// reference to push to
@property (nonatomic, copy) ODReference *reference;

@property (nonatomic, copy) void(^pushNewsfeedCompletionBlock)(NSArray /* ODNewsfeedItem */ *newsfeedItems, NSError *error);

@end
