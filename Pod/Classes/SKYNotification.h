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

NS_ASSUME_NONNULL_BEGIN

/// Undocumented
typedef enum SKYNotificationType : NSInteger {
    SKYNotificationTypeQuery = 1,
    SKYNotificationTypeReadNotification = 3,
    SKYNotificationTypePushNotification = 4,
} SKYNotificationType;

/// Undocumented
@interface SKYNotification : NSObject

/// Undocumented
- (instancetype)init NS_UNAVAILABLE;

/// Undocumented
@property (nonatomic, readonly, copy) SKYNotificationID *notificationID;
/// Undocumented
@property (nonatomic, readonly, assign) SKYNotificationType notificationType;
/// Undocumented
@property (nonatomic, readonly, copy) NSString *containerIdentifier;
/// Undocumented
@property (nonatomic, readonly, copy) NSString *subscriptionID;

/// Undocumented
@property (nonatomic, readonly, assign) BOOL isPruned;

/// Undocumented
@property (nonatomic, readonly, copy) NSString *_Nullable alertBody;
/// Undocumented
@property (nonatomic, readonly, copy) NSString *_Nullable alertLocalizationKey;
/// Undocumented
@property (nonatomic, readonly, copy) NSArray *_Nullable alertLocalizationArgs;
/// Undocumented
@property (nonatomic, readonly, copy) NSString *_Nullable alertActionLocalizationKey;
/// Undocumented
@property (nonatomic, readonly, copy) NSString *_Nullable alertLaunchImage;
/// Undocumented
@property (nonatomic, readonly, copy) NSString *_Nullable soundName;
/// Undocumented
@property (nonatomic, readonly, copy) NSNumber *_Nullable badge;

@end

NS_ASSUME_NONNULL_END
