//
//  SKYContainer.h
//  askq
//
//  Created by Kenji Pa on 19/1/15.
//  Copyright (c) 2015 Rocky Chan. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SKYDatabase.h"
#import "SKYAccessToken.h"
#import "SKYAsset.h"
#import "SKYNotification.h"
#import "SKYPubsub.h"

@protocol SKYContainerDelegate <NSObject>

- (void)container:(SKYContainer *)container didReceiveNotification:(SKYNotification *)notification;

@end

/**
 Notification posted by <SKYContainer> when the current user
 has been updated.
 */
extern NSString *const SKYContainerDidChangeCurrentUserNotification;

/**
 Notification posted by <SKYContainer> when the current device
 has been registered with ourd.
 */
extern NSString *const SKYContainerDidRegisterDeviceNotification;

@class SKYUserRecordID;
@class SKYOperation;

// keep it in sync with SKYUserOperationActionCompletion
typedef void (^SKYContainerUserOperationActionCompletion)(SKYUserRecordID *user, NSError *error);

@interface SKYContainer : NSObject

// seems we need a way to authenticate app
+ (SKYContainer *)defaultContainer;

@property (nonatomic, weak) id<SKYContainerDelegate> delegate;

@property (nonatomic, nonatomic) NSURL *endPointAddress;

@property (nonatomic, readonly) SKYDatabase *publicCloudDatabase;
@property (nonatomic, readonly) SKYDatabase *privateCloudDatabase;

@property (nonatomic, readonly) NSString *containerIdentifier;

@property (nonatomic, readonly) SKYUserRecordID *currentUserRecordID;
@property (nonatomic, readonly) SKYAccessToken *currentAccessToken;

@property (nonatomic, strong) SKYPubsub *pubsubClient;

/**
 Returns the currently registered device ID.
 */
@property (nonatomic, readonly) NSString *registeredDeviceID;

/**
 Returns the API key of the container.
 */
@property (nonatomic, readonly) NSString *APIKey;

// Configuration on the container End-Point, API-Token
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

- (void)addOperation:(SKYOperation *)operation;

/**
 Updates the <currentUserRecordID> and <currentAccessToken>. The updated access credentials are also
 stored in persistent
 storage.

 This method is called when operation sign up, log in and log out is performed using the container's
 convenient
 method and when the operation is completed successfully.

 @see -loadAccessCurrentUserRecordIDAndAccessToken
 */
- (void)updateWithUserRecordID:(SKYUserRecordID *)userRecord
                   accessToken:(SKYAccessToken *)accessToken;

/**
 Set the handler to be called when SKYOperation's subclasses failed to authenticate itself with
 remote server.

 Such circumstance might arise on a container when either:

 1. There are no logged-in users for an opertion that requires users login.
 2. Access token is invalid or has been expired.

 In either cases, developer should prompt for re-authentication of user and login using
 <SKYUserLoginOperation>.

 NOTE: Any attempt to invoke user logout related operation within the set handler will created an
 feedback loop as logouting an invalid access token is also a kind of authentication error.
 */
- (void)setAuthenticationErrorHandler:(void (^)(SKYContainer *container, SKYAccessToken *token,
                                                NSError *error))authErrorHandler;

/**
 Creates an anonymous user account and log in as the created user.

 Use this to create a user that is not associated with an email address. This is a convenient method
 for
 <SKYCreateUserOperation>.
 */
- (void)signupAnonymouslyWithCompletionHandler:
    (SKYContainerUserOperationActionCompletion)completionHandler;

/**
 Creates a user account with the specified username and password.
 */
- (void)signupWithUsername:(NSString *)username
                  password:(NSString *)password
         completionHandler:(SKYContainerUserOperationActionCompletion)completionHandler;

/**
 Creates a user account with the specified email and password.
 */
- (void)signupWithEmail:(NSString *)email
               password:(NSString *)password
      completionHandler:(SKYContainerUserOperationActionCompletion)completionHandler;

/**
 Logs in to an existing user account with the specified username and password.
 */
- (void)loginWithUsername:(NSString *)username
                 password:(NSString *)password
        completionHandler:(SKYContainerUserOperationActionCompletion)completionHandler;

/**
 Logs in to an existing user account with the specified email and password.
 */
- (void)loginWithEmail:(NSString *)email
              password:(NSString *)password
     completionHandler:(SKYContainerUserOperationActionCompletion)completionHandler;

/**
 Logs out the current user of this container.

 This is a convenient method for <SKYUserLogoutOperation>.
 */
- (void)logoutWithCompletionHandler:(SKYContainerUserOperationActionCompletion)completionHandler;

/**
 Registers a device token for push notification.
 */
- (void)registerRemoteNotificationDeviceToken:(NSData *)deviceToken
                            completionHandler:(void (^)(NSString *, NSError *))completionHandler;

/**
 Registers a device without device token.

 This method should be called to register the current device on remote server at the time when
 the application launches. It is okay to call this on subsequent launches, even if a device
 token is already associated with this device.
 */
- (void)registerDeviceCompletionHandler:(void (^)(NSString *, NSError *))completionHandler;

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

@interface SKYContainer (SKYPushOperation)

- (void)pushToUserRecordID:(SKYUserRecordID *)userRecordID alertBody:(NSString *)alertBody;
- (void)pushToUserRecordIDs:(NSArray *)userRecordIDs alertBody:(NSString *)alertBody;

- (void)pushToUserRecordID:(SKYUserRecordID *)userRecordID
      alertLocalizationKey:(NSString *)alertLocalizationKey
     alertLocalizationArgs:(NSArray *)alertLocalizationArgs;
- (void)pushToUserRecordIDs:(NSArray *)userRecordIDs
       alertLocalizationKey:(NSString *)alertLocalizationKey
      alertLocalizationArgs:(NSArray *)alertLocalizationArgs;

@end
