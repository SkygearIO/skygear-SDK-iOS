//
//  ODFetchNotificationChangesOperation.h
//  askq
//
//  Created by Kenji Pa on 6/2/15.
//  Copyright (c) 2015 Rocky Chan. All rights reserved.
//

#import "ODOperation.h"

#import "ODNotification.h"
#import "ODServerChangeToken.h"

@interface ODFetchNotificationChangesOperation : ODOperation

- (instancetype)initWithPreviousServerChangeToken:(ODServerChangeToken *)previousServerChangeToken;

@property (nonatomic, copy) ODServerChangeToken *previousServerChangeToken;
@property (nonatomic, assign) NSUInteger resultsLimit;

// Hmm... shouldn't we just pass it onto fetchNotificationChangesCompletionBlock?
@property (nonatomic, readonly) BOOL moreComing;

@property (nonatomic, copy) void (^notificationChangedBlock)(ODNotification *notification);
@property(nonatomic, copy) void (^fetchNotificationChangesCompletionBlock)( ODServerChangeToken *serverChangeToken, NSError *operationError);

@end
