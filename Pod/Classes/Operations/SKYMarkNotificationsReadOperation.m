//
//  SKYMarkNotificationsReadOperation.m
//  askq
//
//  Created by Kenji Pa on 6/2/15.
//  Copyright (c) 2015 Rocky Chan. All rights reserved.
//

#import "SKYMarkNotificationsReadOperation.h"

@implementation SKYMarkNotificationsReadOperation

- (instancetype)initWithNotificationIDsToMarkRead:(NSArray *)notificationIDs {
    self = [super init];
    if (self) {
        _notificationIDs = notificationIDs;
    }
    return self;
}

+ (instancetype)operationWithNotificationIDsToMarkRead:(NSArray /* SKYNotificationID */ *)notificationIDs
{
    return [[self alloc] initWithNotificationIDsToMarkRead:notificationIDs];
}

@end
