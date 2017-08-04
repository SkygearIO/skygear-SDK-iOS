//
//  SKYPushContainer.h
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

NS_ASSUME_NONNULL_BEGIN

/// Undocumented
@interface SKYPushContainer : NSObject

/**
 Returns the currently registered device ID.
 */
@property (nonatomic, readonly) NSString *_Nullable registeredDeviceID;

/**
 Acknowledge the container that a remote notification is received. If the notification is sent by
 Ourd, container
 would invoke container:didReceiveNotification: on its delegate.
 */
- (void)applicationDidReceiveRemoteNotification:(NSDictionary *)info;

/**
 Registers a device token for push notification.
 */
- (void)registerRemoteNotificationDeviceToken:(NSData *_Nullable)deviceToken
                            completionHandler:
                                (void (^_Nullable)(NSString *_Nullable,
                                                   NSError *_Nullable))completionHandler
    __deprecated;

/**
 Registers a device token for push notification.
 When the user is no longer associated to the device, you should call
 -[SKYContainer unregisterDeviceCompletionHandler:].
 */
- (void)registerDeviceWithDeviceToken:(NSData *_Nullable)deviceToken
                    completionHandler:(void (^_Nullable)(NSString *_Nullable,
                                                         NSError *_Nullable))completionHandler;

/**
 Registers a device without device token. This method should be called when the user denied
 push notification permission.

 This method should be called to register the current device on remote server at the time when
 the application launches. It is okay to call this on subsequent launches, even if a device
 token is already associated with this device.
 */
- (void)registerDeviceCompletionHandler:(void (^_Nullable)(NSString *_Nullable,
                                                           NSError *_Nullable))completionHandler;

/**
 * Unregister the current user from the current device.
 * This should be called when the user logouts.
 */
- (void)unregisterDevice __deprecated;

/**
 * Unregister the current user from the current device, this is preferred to -[unregisterDevice].
 * This should be called when the user logouts.
 *
 * @param completionHandler the completion handler
 *
 */
- (void)unregisterDeviceCompletionHandler:
    (void (^_Nullable)(NSString *_Nullable deviceID, NSError *_Nullable error))completionHandler;

@end

NS_ASSUME_NONNULL_END
