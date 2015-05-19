//
//  ODNotification.m
//  askq
//
//  Created by Kenji Pa on 29/1/15.
//  Copyright (c) 2015 Rocky Chan. All rights reserved.
//

#import "ODNotification_Private.h"

@interface ODNotification()

@property (nonatomic, readwrite, copy) ODNotificationID *notificationID;
@property (nonatomic, readwrite, assign) ODNotificationType notificationType;

@end

@implementation ODNotification

+ (instancetype)notificationFromRemoteNotificationDictionary:(NSDictionary *)notificationDictionary
{
    NSDictionary *info = notificationDictionary[@"_ourd"];
    if (!info) {
        return nil;
    }

    ODNotification *notification = [[self alloc] init];
    // notificationID not implemented, every notification is different.
    // TODO(limouren): implement notificationID when fetch notification is needed.
    notification.notificationID = [[ODNotificationID alloc] init];
    // we only have query notification at the moment
    notification.notificationType = ODNotificationTypeQuery;

    notification.subscriptionID = info[@"subscription-id"];
    return notification;
}

@end
