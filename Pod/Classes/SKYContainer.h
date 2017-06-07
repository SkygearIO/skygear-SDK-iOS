//
//  SKYContainer.h
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

#import "SKYAccessToken.h"
#import "SKYAsset.h"
#import "SKYDatabase.h"
#import "SKYNotification.h"
#import "SKYPubsub.h"
#import "SKYRole.h"

#import "SKYAuthContainer.h"

/// Undocumented
@protocol SKYContainerDelegate <NSObject>

/// Undocumented
- (void)container:(SKYContainer *)container didReceiveNotification:(SKYNotification *)notification;

@end

/**
 Notification posted by <SKYContainer> when the current user
 has been updated.
 */
extern NSString *const SKYContainerDidChangeCurrentUserNotification;

/**
 Notification posted by <SKYContainer> when the current device
 has been registered with skygear.
 */
extern NSString *const SKYContainerDidRegisterDeviceNotification;

@class NSString;
@class SKYOperation;

/// Undocumented
@interface SKYContainer : NSObject

// seems we need a way to authenticate app
/// Undocumented
+ (nonnull SKYContainer *)defaultContainer;

/// Undocumented
@property (nonatomic, readonly) SKYAuthContainer *auth;

/// Undocumented
@property (nonatomic, weak) id<SKYContainerDelegate> delegate;

/// Undocumented
@property (nonatomic, nonatomic) NSURL *endPointAddress;

/// Undocumented
@property (nonatomic, readonly) SKYDatabase *publicCloudDatabase;
/// Undocumented
@property (nonatomic, readonly) SKYDatabase *privateCloudDatabase;

/// Undocumented
@property (nonatomic, readonly) NSString *containerIdentifier;

/// Undocumented
@property (nonatomic, strong) SKYPubsub *pubsubClient;

/**
 Returns the currently registered device ID.
 */
@property (nonatomic, readonly) NSString *registeredDeviceID;

/**
 Returns the API key of the container.
 */
@property (nonatomic, readonly) NSString *APIKey;

/**
 The maximum amount of time to wait before the request is considered timed out.

 The default time interval is 60 seconds.
 */
@property (nonatomic, readwrite) NSTimeInterval defaultTimeoutInterval;

/// Configuration on the container End-Point, API-Token
- (void)configAddress:(NSString *)address;

/**
 Set a new API key to the container.
 */
- (void)configureWithAPIKey:(NSString *)APIKey;

/**
 Acknowledge the container that a remote notification is received. If the notification is sent by
 Ourd, container
 would invoke container:didReceiveNotification: on its delegate.
 */
- (void)applicationDidReceiveRemoteNotification:(NSDictionary *)info;

/// Undocumented
- (void)addOperation:(SKYOperation *)operation;

/**
 Registers a device token for push notification.
 */
- (void)registerRemoteNotificationDeviceToken:(NSData *)deviceToken
                            completionHandler:(void (^)(NSString *, NSError *))completionHandler
    __deprecated;

/**
 Registers a device token for push notification.
 When the user is no longer associated to the device, you should call
 -[SKYContainer unregisterDeviceCompletionHandler:].
 */
- (void)registerDeviceWithDeviceToken:(NSData *)deviceToken
                    completionHandler:(void (^)(NSString *, NSError *))completionHandler;

/**
 Registers a device without device token. This method should be called when the user denied
 push notification permission.

 This method should be called to register the current device on remote server at the time when
 the application launches. It is okay to call this on subsequent launches, even if a device
 token is already associated with this device.
 */
- (void)registerDeviceCompletionHandler:(void (^)(NSString *, NSError *))completionHandler;

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
- (void)unregisterDeviceCompletionHandler:(void (^)(NSString *deviceID,
                                                    NSError *error))completionHandler;

/// Undocumented
- (void)uploadAsset:(SKYAsset *)asset
    completionHandler:(void (^)(SKYAsset *, NSError *))completionHandler;

/**
 Calls a registered lambda function without arguments.
 */
- (void)callLambda:(NSString *)action
    completionHandler:(void (^)(NSDictionary *, NSError *))completionHandler;

/**
 Calls a registered lambda function with arguments.
 */
- (void)callLambda:(NSString *)action
            arguments:(NSArray *)arguments
    completionHandler:(void (^)(NSDictionary *, NSError *))completionHandler;

@end

@interface SKYContainer (SKYRole)

/**
 *  Defines roles to have special powers
 */
- (void)defineAdminRoles:(NSArray<SKYRole *> *)roles
              completion:(void (^)(NSError *error))completionBlock;

/**
 *  Sets default roles for new registered users
 */
- (void)setUserDefaultRole:(NSArray<SKYRole *> *)roles
                completion:(void (^)(NSError *error))completionBlock;

/**
 *  Limit creation access of a record type to some roles
 *
 *  @param recordType      Record type to set creation access
 *  @param roles           Roles can create the record
 *  @param completionBlock Completion Block
 */
- (void)defineCreationAccessWithRecordType:(NSString *)recordType
                                     roles:(NSArray<SKYRole *> *)roles
                                completion:(void (^)(NSError *error))completionBlock;

/**
 *  Set default access of a record type
 *
 *  @param recordType      Record type to set creation access
 *  @param roles           Roles can create the record
 *  @param completionBlock Completion Block
 */
- (void)defineDefaultAccessWithRecordType:(NSString *)recordType
                                   access:(SKYAccessControl *)accessControl
                               completion:(void (^)(NSError *error))completionBlock;

@end
