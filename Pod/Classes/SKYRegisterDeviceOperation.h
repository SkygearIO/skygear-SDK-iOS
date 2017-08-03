//
//  SKYRegisterDeviceOperation.h
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

/// Undocumented
@interface SKYRegisterDeviceOperation : SKYOperation

/// Undocumented
- (instancetype)initWithDeviceToken:(NSData *_Nullable)deviceToken
    __attribute__((deprecated("Use -initWithDeviceToken:topic: instead")));
/// Undocumented
- (instancetype)initWithDeviceToken:(NSData *_Nullable)deviceToken topic:(NSString *_Nullable)topic;

/**
 Returns an instance of operation that registers a device without supplying a device token.

 You can use this method when a device token is not available because the user did not grant
 the permission for remote notification. Notification will arrive through the pubsub mechanism
 instead of remote notification.
 */
+ (instancetype)operation;
/// Undocumented
+ (instancetype)operationWithDeviceToken:(NSData *_Nullable)deviceToken
    __attribute__((deprecated("Use +operationWithDeviceToken:topic: instead")));
/// Undocumented
+ (instancetype)operationWithDeviceToken:(NSData *_Nullable)deviceToken
                                   topic:(NSString *_Nullable)topic;

/// Undocumented
@property (nonatomic, readonly, copy) NSData *_Nullable deviceToken;
/// Undocumented
@property (nonatomic, readonly, copy) NSString *_Nullable topic;
/// Undocumented
@property (nonatomic, readwrite, copy) NSString *_Nullable deviceID;
/// Undocumented
@property (nonatomic, copy) void (^_Nullable registerCompletionBlock)
    (NSString *_Nullable deviceID, NSError *_Nullable error);

@end

NS_ASSUME_NONNULL_END
