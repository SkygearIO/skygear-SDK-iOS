//
//  ODFetchNewsfeedOperation.h
//  askq
//
//  Created by Kenji Pa on 23/1/15.
//  Copyright (c) 2015 Rocky Chan. All rights reserved.
//

#import "ODDatabaseOperation.h"
#import "ODNewsfeed.h"
#import "ODNewsfeedCursor.h"
#import "ODUserRecordID.h"

@interface ODFetchNewsfeedOperation : ODDatabaseOperation

- (instancetype)initForCurrentUserWithNewsFeed:(ODNewsfeed *)newsfeed;
- (instancetype)initWithNewsFeed:(ODNewsfeed *)newsfeed
                forUserRecordID:userRecordID;
- (instancetype)initWithCursor:(ODNewsfeedCursor *)cursor;

@property (nonatomic, readonly) ODNewsfeed *newsfeed;
@property (nonatomic, readonly) ODUserRecordID *userRecordID;
@property (nonatomic, readonly) ODNewsfeedCursor *cursor;

@property (nonatomic, copy) void(^recordFetchedBlock)(ODRecord *record);
@property (nonatomic, copy) void(^fetchCompletionBlock)(ODNewsfeedCursor *cursor, NSError *error);

@end
