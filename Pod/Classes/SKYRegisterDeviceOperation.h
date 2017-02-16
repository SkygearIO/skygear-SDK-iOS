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

@interface SKYRegisterDeviceOperation : SKYOperation

- (instancetype)initWithDeviceToken:(NSData *)deviceToken
    __attribute__((deprecated("Use -initWithDeviceToken:topic: instead")));
- (instancetype)initWithDeviceToken:(NSData *)deviceToken topic:(NSString *)topic;

/**
 Returns an instance of operation that registers a device without supplying a device token.

 You can use this method when a device token is not available because the user did not grant
 the permission for remote notification. Notification will arrive through the pubsub mechanism
 instead of remote notification.
 */
+ (instancetype)operation;
+ (instancetype)operationWithDeviceToken:(NSData *)deviceToken
    __attribute__((deprecated("Use +operationWithDeviceToken:topic: instead")));
+ (instancetype)operationWithDeviceToken:(NSData *)topic topic:(NSString *)topic;

@property (nonatomic, readonly, copy) NSData *deviceToken;
@property (nonatomic, readonly, copy) NSString *topic;
@property (nonatomic, readwrite, copy) NSString *deviceID;
@property (nonatomic, copy) void (^registerCompletionBlock)(NSString *deviceID, NSError *error);

@end
