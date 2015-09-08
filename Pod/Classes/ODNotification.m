//
//  ODNotification.m
//  askq
//
//  Created by Kenji Pa on 29/1/15.
//  Copyright (c) 2015 Rocky Chan. All rights reserved.
//

#import "ODNotification_Private.h"

@implementation ODNotification

- (instancetype)initWithSubscriptionID:(NSString *)subscriptionID
{
    self = [super init];
    if (self) {
        // notificationID not implemented, every notification is different.
        // TODO(limouren): implement notificationID when fetch notification is needed.
        self.notificationID = [[ODNotificationID alloc] init];
        // we only have query notification at the moment
        self.notificationType = ODNotificationTypeQuery;

        self.subscriptionID = subscriptionID;
    }
    return self;
}

@end
