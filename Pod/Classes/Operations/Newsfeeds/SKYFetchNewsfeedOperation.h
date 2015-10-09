//
//  SKYFetchNewsfeedOperation.h
//  askq
//
//  Created by Kenji Pa on 23/1/15.
//  Copyright (c) 2015 Rocky Chan. All rights reserved.
//

#import "SKYDatabaseOperation.h"
#import "SKYNewsfeedCursor.h"
#import "SKYNewsfeedItem.h"
#import "SKYUserRecordID.h"

@interface SKYFetchNewsfeedOperation : SKYDatabaseOperation

+ (instancetype)operationForCurrentUserWithNewsfeedID:(NSString *)newsfeedID;
+ (instancetype)operationWithNewsfeedID:(NSString *)newsfeedID
                           userRecordID:(SKYUserRecordID *)userRecordID;
+ (instancetype)operationWithCursor:(SKYNewsfeedCursor *)cursor;

- (instancetype)initForCurrentUserWithNewsfeedID:(NSString *)newsfeedID;
- (instancetype)initWithNewsfeedID:(NSString *)newsfeedID
                      userRecordID:(SKYUserRecordID *)userRecordID NS_DESIGNATED_INITIALIZER;
- (instancetype)initWithCursor:(SKYNewsfeedCursor *)cursor NS_DESIGNATED_INITIALIZER;

@property (nonatomic, readonly) NSString *newsfeedID;
@property (nonatomic, readonly) SKYUserRecordID *userRecordID;
@property (nonatomic, readonly) SKYNewsfeedCursor *cursor;
@property (nonatomic, assign) NSUInteger resultLimit;
@property (nonatomic, copy) NSArray *results;

@property (nonatomic, copy) void(^newsfeedItemFetchedBlock)(SKYNewsfeedItem *newsfeedItem);
@property (nonatomic, copy) void(^fetchCompletionBlock)(SKYNewsfeedCursor *cursor, NSError *error);

@end
