//
//  SKYAuthContainer.h
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
#import "SKYDatabase.h"

NS_ASSUME_NONNULL_BEGIN

/// Undocumented
@class SKYContainer;

// keep it in sync with SKYUserOperationActionCompletion
/// Undocumented
typedef void (^SKYContainerUserOperationActionCompletion)(SKYRecord *_Nullable user,
                                                          NSError *_Nullable error);

@interface SKYAuthContainer : NSObject

/// Undocumented
@property (nonatomic, readonly) NSString *_Nullable currentUserRecordID;
/// Undocumented
@property (nonatomic, readonly) SKYAccessToken *_Nullable currentAccessToken;
/// Undocumented
@property (nonatomic, readonly) SKYRecord *_Nullable currentUser;

/**
 Updates the <currentUserRecordID> and <currentAccessToken>. The updated access credentials are also
 stored in persistent
 storage.

 This method is called when operation sign up, log in and log out is performed using the container's
 convenient
 method and when the operation is completed successfully.
 */
- (void)updateWithUserRecordID:(NSString *_Nullable)userRecordID
                   accessToken:(SKYAccessToken *_Nullable)accessToken;

/**
 Updates the <currentUser> and <currentAccessToken>. The updated access credentials are also
 stored in persistent storage.

 This method is called when operation sign up, log in and log out is performed using the container's
 convenient
 method and when the operation is completed successfully.
 */
- (void)updateWithUser:(SKYRecord *_Nullable)user
           accessToken:(SKYAccessToken *_Nullable)accessToken;

/**
 Set the handler to be called when SKYOperation's subclasses failed to authenticate itself with
 remote server.

 Such circumstance might arise on a container when either:

 1. There are no logged-in users for an opertion that requires users login.
 2. Access token is invalid or has been expired.

 In either cases, developer should prompt for re-authentication of user and login using
 <SKYLoginUserOperation>.

 NOTE: Any attempt to invoke user logout related operation within the set handler will created an
 feedback loop as logouting an invalid access token is also a kind of authentication error.
 */
- (void)setAuthenticationErrorHandler:(void (^_Nullable)(SKYContainer *container,
                                                         SKYAccessToken *_Nullable token,
                                                         NSError *_Nullable error))authErrorHandler;

@end

@interface SKYAuthContainer (Signup)

/**
 Creates an anonymous user account and log in as the created user.

 Use this to create a user that is not associated with an email address. This is a convenient method
 for
 <SKYSignupUserOperation>.
 */
- (void)signupAnonymouslyWithCompletionHandler:
    (SKYContainerUserOperationActionCompletion _Nullable)completionHandler;

/**
 Creates a user account with the specified auth data and password.
 */
- (void)signupWithAuthData:(NSDictionary *)authData
                  password:(NSString *)password
         completionHandler:(SKYContainerUserOperationActionCompletion _Nullable)completionHandler;

/**
 Creates a user account with the specified auth data, password and profile.
 */
- (void)signupWithAuthData:(NSDictionary *)authData
                  password:(NSString *)password
         profileDictionary:(NSDictionary *_Nullable)profile
         completionHandler:(SKYContainerUserOperationActionCompletion _Nullable)completionHandler;

/**
 Creates a user account with the specified username and password.
 */
- (void)signupWithUsername:(NSString *)username
                  password:(NSString *)password
         completionHandler:(SKYContainerUserOperationActionCompletion _Nullable)completionHandler;

/**
 Creates a user account with the specified email and password.
 */
- (void)signupWithEmail:(NSString *)email
               password:(NSString *)password
      completionHandler:(SKYContainerUserOperationActionCompletion _Nullable)completionHandler;

/**
 Creates a user account with the specified username, password and profile.
 */
- (void)signupWithUsername:(NSString *)username
                  password:(NSString *)password
         profileDictionary:(NSDictionary *_Nullable)profile
         completionHandler:(SKYContainerUserOperationActionCompletion _Nullable)completionHandler;

/**
 Creates a user account with the specified email, password and profile.
 */
- (void)signupWithEmail:(NSString *)email
               password:(NSString *)password
      profileDictionary:(NSDictionary *_Nullable)profile
      completionHandler:(SKYContainerUserOperationActionCompletion _Nullable)completionHandler;

@end

@interface SKYAuthContainer (Login)

/**
 Logs in to an existing user account with the specified auth data and password.
 */
- (void)loginWithAuthData:(NSDictionary *)authData
                 password:(NSString *)password
        completionHandler:(SKYContainerUserOperationActionCompletion _Nullable)completionHandler;

/**
 Logs in to an existing user account with the specified username and password.
 */
- (void)loginWithUsername:(NSString *)username
                 password:(NSString *)password
        completionHandler:(SKYContainerUserOperationActionCompletion _Nullable)completionHandler;

/**
 Logs in to an existing user account with the specified email and password.
 */
- (void)loginWithEmail:(NSString *)email
              password:(NSString *)password
     completionHandler:(SKYContainerUserOperationActionCompletion _Nullable)completionHandler;

/**
 Logs out the current user of this container.

 This is a convenient method for <SKYLogoutUserOperation>.
 */
- (void)logoutWithCompletionHandler:
    (SKYContainerUserOperationActionCompletion _Nullable)completionHandler;

@end

@interface SKYAuthContainer (ChangePasswordMethods)

/**
 Changes the password of the current user of this container.

 This is a convenient method for <SKYChangePasswordOperation>.
 */
- (void)setNewPassword:(NSString *)newPassword
           oldPassword:(NSString *)oldPassword
     completionHandler:(SKYContainerUserOperationActionCompletion _Nullable)completionHandler;

@end

@interface SKYAuthContainer (UserDiscovery)

/**
 *  Asks "Who am I" to server.
 *
 *  @param completionHandler the completion handler
 */
- (void)getWhoAmIWithCompletionHandler:
    (SKYContainerUserOperationActionCompletion _Nullable)completionHandler;

@end

@interface SKYAuthContainer (UserRole)

/**
 *  Defines roles to have special powers
 */
- (void)defineAdminRoles:(NSArray<SKYRole *> *)roles
              completion:(void (^_Nullable)(NSError *_Nullable error))completionBlock;

/**
 *  Sets default roles for new registered users
 */
- (void)setUserDefaultRole:(NSArray<SKYRole *> *)roles
                completion:(void (^_Nullable)(NSError *_Nullable error))completionBlock;

/**
 *  Get roles of users
 *
 *  @param users           Target users
 *  @param completionBlock Completion Block, with a user-to-roles dictionary
 */
- (void)fetchRolesOfUsers:(NSArray<SKYRecord *> *)users
               completion:(void (^_Nullable)(
                              NSDictionary<NSString *, NSArray<SKYRole *> *> *_Nullable userRoles,
                              NSError *_Nullable error))completionBlock;

/**
 *  Get roles of users
 *
 *  @param userIDs         Target user
 *  @param completionBlock Completion Block, with a user-to-roles dictionary
 */
- (void)fetchRolesOfUsersWithUserIDs:(NSArray<NSString *> *)userIDs
                          completion:
                              (void (^_Nullable)(NSDictionary<NSString *, NSArray<NSString *> *>
                                                     *_Nullable userRoles,
                                                 NSError *_Nullable error))completionBlock;

/**
 *  Assign roles to users
 *
 *  @param roles           Roles to be assigned
 *  @param users           Target users
 *  @param completionBlock Completion Block
 */
- (void)assignRoles:(NSArray<SKYRole *> *)roles
            toUsers:(NSArray<SKYRecord *> *)users
         completion:(void (^_Nullable)(NSError *_Nullable error))completionBlock;

/**
 *  Assign roles to users
 *
 *  @param roleNames       Roles to be assigned
 *  @param userIDs         Target users
 *  @param completionBlock Completion Block
 */
- (void)assignRolesWithNames:(NSArray<NSString *> *)roleNames
              toUsersWithIDs:(NSArray<NSString *> *)userIDs
                  completion:(void (^_Nullable)(NSError *_Nullable error))completionBlock;

/**
 *  Revoke roles from users
 *
 *  @param roles           Roles to be revoked
 *  @param users           Target users
 *  @param completionBlock Completion Block
 */
- (void)revokeRoles:(NSArray<SKYRole *> *)roles
          fromUsers:(NSArray<SKYRecord *> *)users
         completion:(void (^_Nullable)(NSError *_Nullable error))completionBlock;

/**
 *  Revoke roles from users
 *
 *  @param roleNames       Roles to be revoked
 *  @param userIDs         Target users
 *  @param completionBlock Completion Block
 */
- (void)revokeRolesWithNames:(NSArray<NSString *> *)roleNames
            fromUsersWihtIDs:(NSArray<NSString *> *)userIDs
                  completion:(void (^_Nullable)(NSError *_Nullable error))completionBlock;

@end

NS_ASSUME_NONNULL_END
