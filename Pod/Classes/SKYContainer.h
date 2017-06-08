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
#import "SKYNotification.h"
#import "SKYPublicDatabase.h"
#import "SKYRole.h"

#import "SKYAuthContainer.h"
#import "SKYPubsubContainer.h"
#import "SKYPushContainer.h"

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
@property (nonatomic, readonly) SKYPubsubContainer *pubsub;

/// Undocumented
@property (nonatomic, readonly) SKYPushContainer *push;

/// Undocumented
@property (nonatomic, weak) id<SKYContainerDelegate> delegate;

/// Undocumented
@property (nonatomic, nonatomic) NSURL *endPointAddress;

/// Undocumented
@property (nonatomic, readonly) SKYPublicDatabase *publicCloudDatabase;
/// Undocumented
@property (nonatomic, readonly) SKYDatabase *privateCloudDatabase;

/// Undocumented
@property (nonatomic, readonly) NSString *containerIdentifier;

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

/// Undocumented
- (void)addOperation:(SKYOperation *)operation;

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
