//
//  ODMarkNotificationsReadOperation.h
//  askq
//
//  Created by Kenji Pa on 6/2/15.
//  Copyright (c) 2015 Rocky Chan. All rights reserved.
//

#import "ODOperation.h"

/**
 `ODMarkNotificationsReadOperation` marks one or more notifications as read in order to:
 
 1. prevent the specfic notification from appearing in the result of an `ODFetchNotifionChangesOperation`; or
 2. decrement app badget if the notification is sent with a `ODNotificationInfo.shouldBadge` set to YES.
 */
@interface ODMarkNotificationsReadOperation : ODOperation

- (instancetype)initWithNotificationIDsToMarkRead:(NSArray /* ODNotificationID */ *)notificationIDs NS_DESIGNATED_INITIALIZER;

+ (instancetype)operationWithNotificationIDsToMarkRead:(NSArray /* ODNotificationID */ *)notificationIDs;

@property(nonatomic, copy) NSArray /* ODNotificationID */ *notificationIDs;

@property(nonatomic, copy) void(^markNotificationsReadCompletionBlock)(NSArray *notificationIDsMarkedRead, NSError *operationError);

@end
