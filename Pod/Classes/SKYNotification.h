//
//  SKYNotification.h
//  ;
//
//  Created by Kenji Pa on 29/1/15.
//  Copyright (c) 2015 Rocky Chan. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SKYNotificationID.h"

typedef enum SKYNotificationType : NSInteger {
    SKYNotificationTypeQuery = 1,
    SKYNotificationTypeReadNotification = 3,
    SKYNotificationTypePushNotification = 4,
} SKYNotificationType;

@interface SKYNotification : NSObject

- (instancetype)init NS_UNAVAILABLE;

@property (nonatomic, readonly, copy) SKYNotificationID *notificationID;
@property (nonatomic, readonly, assign) SKYNotificationType notificationType;
@property (nonatomic, readonly, copy) NSString *containerIdentifier;

@property (nonatomic, readonly, assign) BOOL isPruned;

@property (nonatomic, readonly, copy) NSString *alertBody;
@property (nonatomic, readonly, copy) NSString *alertLocalizationKey;
@property (nonatomic, readonly, copy) NSArray *alertLocalizationArgs;
@property (nonatomic, readonly, copy) NSString *alertActionLocalizationKey;
@property (nonatomic, readonly, copy) NSString *alertLaunchImage;
@property (nonatomic, readonly, copy) NSString *soundName;
@property (nonatomic, readonly, copy) NSNumber *badge;

@end
