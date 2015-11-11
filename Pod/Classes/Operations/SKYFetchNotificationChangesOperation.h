//
//  SKYFetchNotificationChangesOperation.h
//  askq
//
//  Created by Kenji Pa on 6/2/15.
//  Copyright (c) 2015 Rocky Chan. All rights reserved.
//

#import "SKYOperation.h"

#import "SKYNotification.h"
#import "SKYServerChangeToken.h"

@interface SKYFetchNotificationChangesOperation : SKYOperation

- (instancetype)initWithPreviousServerChangeToken:(SKYServerChangeToken *)previousServerChangeToken;

+ (instancetype)operationWithPreviousServerChangeToken:
    (SKYServerChangeToken *)previousServerChangeToken;

@property (nonatomic, copy) SKYServerChangeToken *previousServerChangeToken;
@property (nonatomic, assign) NSUInteger resultsLimit;

// Hmm... shouldn't we just pass it onto fetchNotificationChangesCompletionBlock?
@property (nonatomic, readonly) BOOL moreComing;

@property (nonatomic, copy) void (^notificationChangedBlock)(SKYNotification *notification);
@property (nonatomic, copy) void (^fetchNotificationChangesCompletionBlock)
    (SKYServerChangeToken *serverChangeToken, NSError *operationError);

@end
