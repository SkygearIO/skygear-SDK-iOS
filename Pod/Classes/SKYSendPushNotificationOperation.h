//
//  SKYSendPushNotificationOperation.h
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

#import "SKYOperation.h"
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class SKYNotificationInfo;

/// Undocumented
typedef enum : NSUInteger {
    SKYPushTargetIsDevice,
    SKYPushTargetIsUser,
} SKYPushTarget;

/// Undocumented
@interface SKYSendPushNotificationOperation : SKYOperation

/// Undocumented
- (instancetype)initWithNotificationInfo:(SKYNotificationInfo *)notificationInfo
                              pushTarget:(SKYPushTarget)pushTarget
                               IDsToSend:(NSArray *)IDsToSend;

/// Undocumented
- (instancetype)initWithNotificationInfo:(SKYNotificationInfo *)notificationInfo
                              pushTarget:(SKYPushTarget)pushTarget
                               IDsToSend:(NSArray *)IDsToSend
                                   topic:(NSString *_Nullable)topic;

/// Undocumented
+ (instancetype)operationWithNotificationInfo:(SKYNotificationInfo *)notificationInfo
                                userIDsToSend:(NSArray *)userIDsToSend;

/// Undocumented
+ (instancetype)operationWithNotificationInfo:(SKYNotificationInfo *)notificationInfo
                                userIDsToSend:(NSArray *)userIDsToSend
                                        topic:(NSString *_Nullable)topic;

/// Undocumented
+ (instancetype)operationWithNotificationInfo:(SKYNotificationInfo *)notificationInfo
                              deviceIDsToSend:(NSArray *)deviceIDsToSend;

/// Undocumented
+ (instancetype)operationWithNotificationInfo:(SKYNotificationInfo *)notificationInfo
                              deviceIDsToSend:(NSArray *)deviceIDsToSend
                                        topic:(NSString *_Nullable)topic;

/// Undocumented
@property (nonatomic, readwrite, copy) SKYNotificationInfo *notificationInfo;
/// Undocumented
@property (nonatomic, readwrite) SKYPushTarget pushTarget;
/// Undocumented
@property (nonatomic, readwrite, copy) NSArray *IDsToSend;
/// Undocumented
@property (nonatomic, readwrite, copy) NSString *_Nullable topic;
/// Undocumented
@property (nonatomic, copy) void (^_Nullable perSendCompletionHandler)
    (NSString *_Nullable userID, NSError *_Nullable error);
/// Undocumented
@property (nonatomic, copy) void (^_Nullable sendCompletionHandler)
    (NSArray *_Nullable userIDs, NSError *_Nullable error);

@end

NS_ASSUME_NONNULL_END
