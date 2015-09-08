//
//  ODNotification_Private
//  ;
//
//  Created by Kenji Pa on 29/1/15.
//  Copyright (c) 2015 Rocky Chan. All rights reserved.
//

#import "ODNotification.h"

@interface ODNotification()

- (instancetype)initWithSubscriptionID:(NSString *)subscriptionID;

@property (nonatomic, readwrite, copy) ODNotificationID *notificationID;
@property (nonatomic, readwrite, assign) ODNotificationType notificationType;
@property (nonatomic, readwrite, copy) NSString *subscriptionID;

@end
