//
//  SKYNotification.h
//  SKYKit
//
//  Copyright 2015 Oursky Ltd.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
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
@property (nonatomic, readonly, copy) NSString *subscriptionID;

@property (nonatomic, readonly, assign) BOOL isPruned;

@property (nonatomic, readonly, copy) NSString *alertBody;
@property (nonatomic, readonly, copy) NSString *alertLocalizationKey;
@property (nonatomic, readonly, copy) NSArray *alertLocalizationArgs;
@property (nonatomic, readonly, copy) NSString *alertActionLocalizationKey;
@property (nonatomic, readonly, copy) NSString *alertLaunchImage;
@property (nonatomic, readonly, copy) NSString *soundName;
@property (nonatomic, readonly, copy) NSNumber *badge;

@end
