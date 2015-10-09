//
//  SKYNotification.m
//  askq
//
//  Created by Kenji Pa on 29/1/15.
//  Copyright (c) 2015 Rocky Chan. All rights reserved.
//

#import "SKYNotification_Private.h"

@implementation SKYNotification

- (instancetype)initWithSubscriptionID:(NSString *)subscriptionID
{
    self = [super init];
    if (self) {
        // notificationID not implemented, every notification is different.
        // TODO(limouren): implement notificationID when fetch notification is needed.
        self.notificationID = [[SKYNotificationID alloc] init];
        // we only have query notification at the moment
        self.notificationType = SKYNotificationTypeQuery;

        self.subscriptionID = subscriptionID;
    }
    return self;
}

@end
