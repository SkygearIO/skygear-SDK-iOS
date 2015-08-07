//
//  ODMarkNotificationsReadOperation.m
//  askq
//
//  Created by Kenji Pa on 6/2/15.
//  Copyright (c) 2015 Rocky Chan. All rights reserved.
//

#import "ODMarkNotificationsReadOperation.h"

@implementation ODMarkNotificationsReadOperation

- (instancetype)initWithNotificationIDsToMarkRead:(NSArray *)notificationIDs {
    self = [super init];
    if (self) {
        _notificationIDs = notificationIDs;
    }
    return self;
}

+ (instancetype)operationWithNotificationIDsToMarkRead:(NSArray /* ODNotificationID */ *)notificationIDs
{
    return [[self alloc] initWithNotificationIDsToMarkRead:notificationIDs];
}

@end
