//
//  SKYNotification_Private
//  ;
//
//  Created by Kenji Pa on 29/1/15.
//  Copyright (c) 2015 Rocky Chan. All rights reserved.
//

#import "SKYNotification.h"

@interface SKYNotification ()

- (instancetype)initWithSubscriptionID:(NSString *)subscriptionID;

@property (nonatomic, readwrite, copy) SKYNotificationID *notificationID;
@property (nonatomic, readwrite, assign) SKYNotificationType notificationType;
@property (nonatomic, readwrite, copy) NSString *subscriptionID;

@end
