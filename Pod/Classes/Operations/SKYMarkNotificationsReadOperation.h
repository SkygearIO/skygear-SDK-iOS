//
//  SKYMarkNotificationsReadOperation.h
//  askq
//
//  Created by Kenji Pa on 6/2/15.
//  Copyright (c) 2015 Rocky Chan. All rights reserved.
//

#import "SKYOperation.h"

/**
 `SKYMarkNotificationsReadOperation` marks one or more notifications as read in order to:
 
 1. prevent the specfic notification from appearing in the result of an `SKYFetchNotifionChangesOperation`; or
 2. decrement app badget if the notification is sent with a `SKYNotificationInfo.shouldBadge` set to YES.
 */
@interface SKYMarkNotificationsReadOperation : SKYOperation

- (instancetype)initWithNotificationIDsToMarkRead:(NSArray /* SKYNotificationID */ *)notificationIDs NS_DESIGNATED_INITIALIZER;

+ (instancetype)operationWithNotificationIDsToMarkRead:(NSArray /* SKYNotificationID */ *)notificationIDs;

@property(nonatomic, copy) NSArray /* SKYNotificationID */ *notificationIDs;

@property(nonatomic, copy) void(^markNotificationsReadCompletionBlock)(NSArray *notificationIDsMarkedRead, NSError *operationError);

@end
