//
//  ODContainer.h
//  askq
//
//  Created by Kenji Pa on 19/1/15.
//  Copyright (c) 2015 Rocky Chan. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ODDatabase.h"
#import "ODAccessToken.h"
#import "ODAsset.h"
#import "ODPubsub.h"

/**
 Notification posted by <ODContainer> when the current user
 has been updated.
 */
extern NSString * const ODContainerDidChangeCurrentUserNotification;

/**
 Notification posted by <ODContainer> when the current device
 has been registered with ourd.
 */
extern NSString *const ODContainerDidRegisterDeviceNotification;

@class ODUserRecordID;
@class ODOperation;

// keep it in sync with ODUserOperationActionCompletion
typedef void(^ODContainerUserOperationActionCompletion)(ODUserRecordID *user, NSError *error);

@interface ODContainer : NSObject

// seems we need a way to authenticate app
+ (ODContainer *)defaultContainer;

@property (nonatomic, weak) id<ODContainerDelegate> delegate;

@property (nonatomic, nonatomic) NSURL *endPointAddress;

@property (nonatomic, readonly) ODDatabase *publicCloudDatabase;
@property (nonatomic, readonly) ODDatabase *privateCloudDatabase;

@property (nonatomic, readonly) NSString *containerIdentifier;

@property (nonatomic, readonly) ODUserRecordID *currentUserRecordID;
@property (nonatomic, readonly) ODAccessToken *currentAccessToken;

@property (nonatomic, strong) ODPubsub *pubsubClient;

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

- (void)addOperation:(ODOperation *)operation;

- (void)signupUserWithUsername:(NSString *)username password:(NSString *)password completionHandler:(ODContainerUserOperationActionCompletion)completionHandler;
/**
 Updates the <currentUserRecordID> and <currentAccessToken>. The updated access credentials are also stored in persistent
 storage.
 
 This method is called when operation sign up, log in and log out is performed using the container's convenient
 method and when the operation is completed successfully.
 
 @see -loadAccessCurrentUserRecordIDAndAccessToken
 */
- (void)updateWithUserRecordID:(ODUserRecordID *)userRecord accessToken:(ODAccessToken *)accessToken;

/**
 Set the handler to be called when ODOperation's subclasses failed to authenticate itself with remote server.

 Such circumstance might arise on a container when either:

 1. There are no logged-in users for an opertion that requires users login.
 2. Access token is invalid or has been expired.

 In either cases, developer should prompt for re-authentication of user and login using <ODUserLoginOperation>.

 NOTE: Any attempt to invoke user logout related operation within the set handler will created an feedback loop as logouting an invalid access token is also a kind of authentication error.
 */
- (void)setAuthenticationErrorHandler:(void(^)(ODContainer *container, ODAccessToken *token, NSError *error))authErrorHandler;

/**
 Creates an anonymous user account and log in as the created user.
 
 Use this to create a user that is not associated with an email address. This is a convenient method for
 <ODCreateUserOperation>.
 */
- (void)signupUserAnonymouslyWithCompletionHandler:(ODContainerUserOperationActionCompletion)completionHandler;
- (void)loginUserWithUsername:(NSString *)username password:(NSString *)password completionHandler:(ODContainerUserOperationActionCompletion)completionHandler;

/**
 Logs out the current user of this container.
 
 This is a convenient method for <ODUserLogoutOperation>.
 */
- (void)logoutUserWithcompletionHandler:(ODContainerUserOperationActionCompletion)completionHandler;

/**
 Registers a device token for push notification.
 */
- (void)registerRemoteNotificationDeviceToken:(NSData *)deviceToken completionHandler:(void(^)(NSString *, NSError *))completionHandler;

- (void)uploadAsset:(ODAsset *)asset completionHandler:(void(^)(ODAsset *, NSError*))completionHandler;

/**
 Calls a registered lambda function without arguments.
 */
- (void)callLambda:(NSString *)action
 completionHandler:(void(^)(NSDictionary *, NSError *))completionHandler;

/**
 Calls a registered lambda function with arguments.
 */
- (void)callLambda:(NSString *)action
         arguments:(NSArray *)arguments
 completionHandler:(void(^)(NSDictionary *, NSError *))completionHandler;

@end

@interface ODContainer (ODPushOperation)

- (void)pushToUserRecordID:(ODUserRecordID *)userRecordID alertBody:(NSString *)alertBody;
- (void)pushToUserRecordIDs:(NSArray *)userRecordIDs alertBody:(NSString *)alertBody;

- (void)pushToUserRecordID:(ODUserRecordID *)userRecordID alertLocalizationKey:(NSString *)alertLocalizationKey alertLocalizationArgs:(NSArray *)alertLocalizationArgs;
- (void)pushToUserRecordIDs:(NSArray *)userRecordIDs alertLocalizationKey:(NSString *)alertLocalizationKey alertLocalizationArgs:(NSArray *)alertLocalizationArgs;

@end
