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

@class SKYNotificationInfo;

typedef enum : NSUInteger {
    SKYPushTargetIsDevice,
    SKYPushTargetIsUser,
} SKYPushTarget;

@interface SKYSendPushNotificationOperation : SKYOperation

- (instancetype)initWithNotificationInfo:(SKYNotificationInfo *)notificationInfo
                              pushTarget:(SKYPushTarget)pushTarget
                               IDsToSend:(NSArray *)IDsToSend;

- (instancetype)initWithNotificationInfo:(SKYNotificationInfo *)notificationInfo
                              pushTarget:(SKYPushTarget)pushTarget
                               IDsToSend:(NSArray *)IDsToSend
                                   topic:(NSString *)topic;

+ (instancetype)operationWithNotificationInfo:(SKYNotificationInfo *)notificationInfo
                                userIDsToSend:(NSArray *)userIDsToSend;

+ (instancetype)operationWithNotificationInfo:(SKYNotificationInfo *)notificationInfo
                                userIDsToSend:(NSArray *)userIDsToSend
                                        topic:(NSString *)topic;

+ (instancetype)operationWithNotificationInfo:(SKYNotificationInfo *)notificationInfo
                              deviceIDsToSend:(NSArray *)deviceIDsToSend;

+ (instancetype)operationWithNotificationInfo:(SKYNotificationInfo *)notificationInfo
                              deviceIDsToSend:(NSArray *)deviceIDsToSend
                                        topic:(NSString *)topic;

@property (nonatomic, readwrite, copy) SKYNotificationInfo *notificationInfo;
@property (nonatomic, readwrite) SKYPushTarget pushTarget;
@property (nonatomic, readwrite, copy) NSArray *IDsToSend;
@property (nonatomic, readwrite, copy) NSString *topic;
@property (nonatomic, copy) void (^perSendCompletionHandler)(NSString *userID, NSError *error);
@property (nonatomic, copy) void (^sendCompletionHandler)(NSArray *userIDs, NSError *error);

@end
