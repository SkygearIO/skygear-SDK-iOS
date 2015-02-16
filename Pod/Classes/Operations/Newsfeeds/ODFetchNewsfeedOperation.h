//
//  ODFetchNewsfeedOperation.h
//  askq
//
//  Created by Kenji Pa on 23/1/15.
//  Copyright (c) 2015 Rocky Chan. All rights reserved.
//

#import "ODDatabaseOperation.h"
#import "ODNewsfeedCursor.h"
#import "ODNewsfeedItem.h"
#import "ODUserRecordID.h"

@interface ODFetchNewsfeedOperation : ODDatabaseOperation

+ (instancetype)operationForCurrentUserWithNewsfeedID:(NSString *)newsfeedID;
+ (instancetype)operationWithNewsfeedID:(NSString *)newsfeedID
                           userRecordID:(ODUserRecordID *)userRecordID;

- (instancetype)initForCurrentUserWithNewsfeedID:(NSString *)newsfeedID;
- (instancetype)initWithNewsfeedID:(NSString *)newsfeedID
                      userRecordID:(ODUserRecordID *)userRecordID NS_DESIGNATED_INITIALIZER;
- (instancetype)initWithCursor:(ODNewsfeedCursor *)cursor NS_DESIGNATED_INITIALIZER;

@property (nonatomic, readonly) NSString *newsfeedID;
@property (nonatomic, readonly) ODUserRecordID *userRecordID;
@property (nonatomic, readonly) ODNewsfeedCursor *cursor;
@property (nonatomic, assign) NSUInteger resultLimit;
@property (nonatomic, copy) NSArray *results;

@property (nonatomic, copy) void(^newsfeedItemFetchedBlock)(ODNewsfeedItem *newsfeedItem);
@property (nonatomic, copy) void(^fetchCompletionBlock)(ODNewsfeedCursor *cursor, NSError *error);

@end
