//
//  SKYAuthContainer.m
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

#import "SKYAuthContainer.h"
#import "SKYAuthContainer_Private.h"

#import "UICKeyChainStore.h"

#import "SKYAccessToken.h"
#import "SKYContainer.h"
#import "SKYError.h"
#import "SKYQuery.h"

#import "SKYAssignUserRoleOperation.h"
#import "SKYChangePasswordOperation.h"
#import "SKYDefineAdminRolesOperation.h"
#import "SKYFetchUserRoleOperation.h"
#import "SKYGetCurrentUserOperation.h"
#import "SKYLambdaOperation.h"
#import "SKYLoginUserOperation.h"
#import "SKYLogoutUserOperation.h"
#import "SKYQueryOperation.h"
#import "SKYRecordDeserializer.h"
#import "SKYRevokeUserRoleOperation.h"
#import "SKYSetDisableUserOperation.h"
#import "SKYSetUserDefaultRoleOperation.h"
#import "SKYSignupUserOperation.h"

NSString *const SKYContainerCurrentUserRecordIDKey = @"SKYContainerCurrentUserRecordID";
NSString *const SKYContainerAccessTokenKey = @"SKYContainerAccessToken";
NSString *const SKYContainerCurrentUserRecordKey = @"SKYContainerCurrentUserRecord";

@implementation SKYAuthContainer {
    SKYAccessToken *_accessToken;
    NSString *_userRecordID;
    SKYRecord *_currentUser;
    BOOL _currentUserDataEncryptionEnabled;
}

#pragma mark - private

- (instancetype)init
{
    self = [super init];
    if (self) {
        _currentUserDataEncryptionEnabled = NO;
    }
    return self;
}

- (instancetype)initWithContainer:(SKYContainer *)container
{
    self = [super init];
    if (self) {
        self.container = container;
    }
    return self;
}

- (void)loadCurrentUserAndAccessToken
{
    if (_currentUserDataEncryptionEnabled) {
        [self loadCurrentUserAndAccessTokenFromKeychain];
    } else {
        [self loadCurrentUserAndAccessTokenFromUserDefaults];
    }
}

- (void)loadCurrentUserAndAccessTokenFromKeychain
{
    NSString *appBundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
    UICKeyChainStore *keychain = [UICKeyChainStore keyChainStoreWithService:appBundleIdentifier];
    keychain.accessibility = UICKeyChainStoreAccessibilityAfterFirstUnlock;

    NSString *accessToken = [keychain stringForKey:SKYContainerAccessTokenKey];
    NSData *encodedUser = [keychain dataForKey:SKYContainerCurrentUserRecordKey];

    SKYRecord *user = nil;
    if ([encodedUser isKindOfClass:[NSData class]]) {
        user = [NSKeyedUnarchiver unarchiveObjectWithData:encodedUser];
    }

    if (accessToken && user) {
        _currentUser = user;
        _userRecordID = user.recordID;
        _accessToken = [[SKYAccessToken alloc] initWithTokenString:accessToken];
    } else {
        _currentUser = nil;
        _userRecordID = nil;
        _accessToken = nil;
    }
}

- (void)loadCurrentUserAndAccessTokenFromUserDefaults
{
    NSString *userRecordID =
        [[NSUserDefaults standardUserDefaults] objectForKey:SKYContainerCurrentUserRecordIDKey];
    NSString *accessToken =
        [[NSUserDefaults standardUserDefaults] objectForKey:SKYContainerAccessTokenKey];
    SKYRecord *user = nil;
    NSData *encodedUser =
        [[NSUserDefaults standardUserDefaults] objectForKey:SKYContainerCurrentUserRecordKey];
    if ([encodedUser isKindOfClass:[NSData class]]) {
        user = [NSKeyedUnarchiver unarchiveObjectWithData:encodedUser];
    }

    if (accessToken && (userRecordID || user)) {
        _currentUser = user;
        if (user) {
            _userRecordID = user.recordID;
        } else {
            _userRecordID = userRecordID;
        }
        _accessToken = [[SKYAccessToken alloc] initWithTokenString:accessToken];
    } else {
        _currentUser = nil;
        _userRecordID = nil;
        _accessToken = nil;
    }
}

- (void)handleAuthResponse:(NSDictionary<NSString *, id> *)authResponse
{
    NSDictionary *profile = authResponse[@"profile"];
    if (![profile isKindOfClass:[NSDictionary class]]) {
        NSLog(@"didCompleteWithAuthResponse error: No profile dictionary.");
        return;
    }

    NSString *tokenString = authResponse[@"access_token"];
    if (![tokenString isKindOfClass:[NSString class]]) {
        NSLog(@"didCompleteWithAuthResponse error: No access_token string.");
        return;
    }

    SKYRecord *user = [[SKYRecordDeserializer deserializer] recordWithDictionary:profile];
    SKYAccessToken *accessToken = [[SKYAccessToken alloc] initWithTokenString:tokenString];

    [self updateWithUser:user accessToken:accessToken];
}

- (void)operation:(id)operation
    didCompleteWithAuthResponse:(NSDictionary<NSString *, id> *)authResponse
{
    [self handleAuthResponse:authResponse];
}

#pragma mark -

- (SKYAccessToken *)currentAccessToken
{
    return _accessToken;
}

- (NSString *)currentUserRecordID
{
    return _userRecordID;
}

- (void)saveCurrentUserAndAccessToken
{
    if (_currentUserDataEncryptionEnabled) {
        [self saveCurrentUserAndAccessTokenToKeychain];
    } else {
        [self saveCurrentUserAndAccessTokenToUserDefaults];
    }
}

- (void)saveCurrentUserAndAccessTokenToKeychain
{
    NSString *appBundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
    UICKeyChainStore *keychain = [UICKeyChainStore keyChainStoreWithService:appBundleIdentifier];
    keychain.accessibility = UICKeyChainStoreAccessibilityAfterFirstUnlock;

    if (_accessToken && _currentUser) {
        [keychain setData:[NSKeyedArchiver archivedDataWithRootObject:_currentUser]
                   forKey:SKYContainerCurrentUserRecordKey];
        [keychain setString:_accessToken.tokenString forKey:SKYContainerAccessTokenKey];
    } else {
        [keychain removeItemForKey:SKYContainerAccessTokenKey];
        [keychain removeItemForKey:SKYContainerCurrentUserRecordKey];
    }
}

- (void)saveCurrentUserAndAccessTokenToUserDefaults
{
    if (_accessToken && (_userRecordID || _currentUser)) {
        if (_userRecordID) {
            [[NSUserDefaults standardUserDefaults] setObject:_userRecordID
                                                      forKey:SKYContainerCurrentUserRecordIDKey];
        }
        if (_currentUser) {
            [[NSUserDefaults standardUserDefaults]
                setObject:[NSKeyedArchiver archivedDataWithRootObject:_currentUser]
                   forKey:SKYContainerCurrentUserRecordKey];
        }
        [[NSUserDefaults standardUserDefaults] setObject:_accessToken.tokenString
                                                  forKey:SKYContainerAccessTokenKey];
    } else {
        [[NSUserDefaults standardUserDefaults]
            removeObjectForKey:SKYContainerCurrentUserRecordIDKey];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:SKYContainerAccessTokenKey];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:SKYContainerCurrentUserRecordKey];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)setCurrentUserDataEncryptionEnable:(BOOL)enabled
{
    _currentUserDataEncryptionEnabled = enabled;
}

- (void)updateWithUserRecordID:(NSString *)userRecordID accessToken:(SKYAccessToken *)accessToken
{
    if (userRecordID && accessToken) {
        _userRecordID = userRecordID;
        _accessToken = accessToken;
        _currentUser = nil;
    } else {
        _userRecordID = nil;
        _accessToken = nil;
        _currentUser = nil;
    }

    [self saveCurrentUserAndAccessToken];

    [[NSNotificationCenter defaultCenter]
        postNotificationName:SKYContainerDidChangeCurrentUserNotification
                      object:self
                    userInfo:nil];
}

- (void)updateWithUser:(SKYRecord *)user accessToken:(SKYAccessToken *)accessToken
{
    BOOL needRegisterDevice = user && ![user.recordID isEqualToString:_userRecordID];

    if (user && accessToken) {
        _userRecordID = user.recordID;
        _accessToken = accessToken;
        _currentUser = user;
    } else {
        _userRecordID = nil;
        _accessToken = nil;
        _currentUser = nil;
    }

    [self saveCurrentUserAndAccessToken];

    NSLog(@"User logged in with UserRecordID %@.", user.recordID);

    // register device when current user change
    if (needRegisterDevice) {
        [self.container.push registerDeviceCompletionHandler:nil];
    }

    [[NSNotificationCenter defaultCenter]
        postNotificationName:SKYContainerDidChangeCurrentUserNotification
                      object:self
                    userInfo:nil];
}

- (void)setAuthenticationErrorHandler:(void (^)(SKYContainer *container, SKYAccessToken *token,
                                                NSError *error))authErrorHandler
{
    _authErrorHandler = authErrorHandler;
}

#pragma mark -

/**
 Creates a user account with the specified auth data and password.
 */
- (void)signupWithAuthData:(NSDictionary *)authData
                  password:(NSString *)password
         completionHandler:(SKYContainerUserOperationActionCompletion)completionHandler
{
    SKYSignupUserOperation *operation =
        [SKYSignupUserOperation operationWithAuthData:authData password:password];
    operation.authResponseDelegate = self;
    operation.signupCompletionBlock =
        ^(SKYRecord *user, SKYAccessToken *accessToken, NSError *error) {
            if (completionHandler) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    completionHandler(user, error);
                });
            }
        };
    [self.container addOperation:operation];
}

/**
 Creates a user account with the specified auth data, password and profile.
 */
- (void)signupWithAuthData:(NSDictionary *)authData
                  password:(NSString *)password
         profileDictionary:(NSDictionary *)profile
         completionHandler:(SKYContainerUserOperationActionCompletion)completionHandler
{
    SKYSignupUserOperation *operation =
        [SKYSignupUserOperation operationWithAuthData:authData password:password profile:profile];
    operation.authResponseDelegate = self;
    operation.signupCompletionBlock =
        ^(SKYRecord *user, SKYAccessToken *accessToken, NSError *error) {
            if (completionHandler) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    completionHandler(user, error);
                });
            }
        };
    [self.container addOperation:operation];
}

- (void)signupWithUsername:(NSString *)username
                  password:(NSString *)password
         completionHandler:(SKYContainerUserOperationActionCompletion)completionHandler
{
    [self signupWithAuthData:@{@"username" : username}
                    password:password
           completionHandler:completionHandler];
}

- (void)signupWithEmail:(NSString *)email
               password:(NSString *)password
      completionHandler:(SKYContainerUserOperationActionCompletion)completionHandler
{
    [self signupWithAuthData:@{@"email" : email}
                    password:password
           completionHandler:completionHandler];
}

/**
 Creates a user account with the specified username, password and profile.
 */
- (void)signupWithUsername:(NSString *)username
                  password:(NSString *)password
         profileDictionary:(NSDictionary *)profile
         completionHandler:(SKYContainerUserOperationActionCompletion)completionHandler
{
    [self signupWithAuthData:@{@"username" : username}
                    password:password
           profileDictionary:profile
           completionHandler:completionHandler];
}

/**
 Creates a user account with the specified email, password and profile.
 */
- (void)signupWithEmail:(NSString *)email
               password:(NSString *)password
      profileDictionary:(NSDictionary *)profile
      completionHandler:(SKYContainerUserOperationActionCompletion)completionHandler
{
    [self signupWithAuthData:@{@"email" : email}
                    password:password
           profileDictionary:profile
           completionHandler:completionHandler];
}

- (void)signupAnonymouslyWithCompletionHandler:
    (SKYContainerUserOperationActionCompletion)completionHandler
{
    SKYSignupUserOperation *operation = [SKYSignupUserOperation operationWithAnonymousUser];
    operation.authResponseDelegate = self;
    operation.signupCompletionBlock =
        ^(SKYRecord *user, SKYAccessToken *accessToken, NSError *error) {
            if (completionHandler) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    completionHandler(user, error);
                });
            }
        };
    [self.container addOperation:operation];
}

- (void)loginWithAuthData:(NSDictionary *)authData
                 password:(NSString *)password
        completionHandler:(SKYContainerUserOperationActionCompletion)completionHandler
{
    SKYLoginUserOperation *operation =
        [SKYLoginUserOperation operationWithAuthData:authData password:password];
    operation.authResponseDelegate = self;
    operation.loginCompletionBlock =
        ^(SKYRecord *user, SKYAccessToken *accessToken, NSError *error) {
            if (completionHandler) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    completionHandler(user, error);
                });
            }
        };
    [self.container addOperation:operation];
}

- (void)loginWithUsername:(NSString *)username
                 password:(NSString *)password
        completionHandler:(SKYContainerUserOperationActionCompletion)completionHandler
{
    [self loginWithAuthData:@{@"username" : username}
                   password:password
          completionHandler:completionHandler];
}

- (void)loginWithEmail:(NSString *)email
              password:(NSString *)password
     completionHandler:(SKYContainerUserOperationActionCompletion)completionHandler
{
    [self loginWithAuthData:@{@"email" : email}
                   password:password
          completionHandler:completionHandler];
}

- (void)logoutWithCompletionHandler:(SKYContainerUserOperationActionCompletion)completionHandler
{
    SKYLogoutUserOperation *logoutOperation = [[SKYLogoutUserOperation alloc] init];

    __weak typeof(self) weakSelf = self;
    logoutOperation.logoutCompletionBlock = ^(NSError *error) {
        if (error) {
            // Any of the following error code will be treated as successful logout
            switch (error.code) {
                case SKYErrorNotAuthenticated:
                case SKYErrorAccessKeyNotAccepted:
                case SKYErrorAccessTokenNotAccepted:
                    error = nil;
            }
        }
        if (!error) {
            [weakSelf updateWithUser:nil accessToken:nil];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            completionHandler(nil, error);
        });
    };

    NSString *deviceID = self.container.push.registeredDeviceID;
    if (deviceID != nil) {
        [self.container.push
            unregisterDeviceCompletionHandler:^(NSString *deviceID, NSError *error) {
                if (error != nil) {
                    NSLog(@"Warning: Failed to unregister device: %@", error.localizedDescription);
                }

                [weakSelf.container addOperation:logoutOperation];
            }];
    } else {
        [self.container addOperation:logoutOperation];
    }
}

- (void)setNewPassword:(NSString *)newPassword
           oldPassword:(NSString *)oldPassword
     completionHandler:(SKYContainerUserOperationActionCompletion)completionHandler
{
    SKYChangePasswordOperation *operation =
        [SKYChangePasswordOperation operationWithOldPassword:oldPassword passwordToSet:newPassword];
    operation.authResponseDelegate = self;
    operation.changePasswordCompletionBlock =
        ^(SKYRecord *user, SKYAccessToken *accessToken, NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completionHandler(user, error);
            });
        };

    [self.container addOperation:operation];
}

- (void)getWhoAmIWithCompletionHandler:(SKYContainerUserOperationActionCompletion)completionHandler
{
    SKYGetCurrentUserOperation *operation = [[SKYGetCurrentUserOperation alloc] init];
    operation.authResponseDelegate = self;
    operation.getCurrentUserCompletionBlock =
        ^(SKYRecord *user, SKYAccessToken *accessToken, NSError *error) {
            if (completionHandler) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    completionHandler(user, error);
                });
            }
        };
    [self.container addOperation:operation];
}

#pragma mark -

- (void)defineAdminRoles:(NSArray<SKYRole *> *)roles
              completion:(void (^)(NSError *error))completionBlock
{
    SKYDefineAdminRolesOperation *operation =
        [SKYDefineAdminRolesOperation operationWithRoles:roles];

    operation.defineAdminRolesCompletionBlock = ^(NSArray<SKYRole *> *roles, NSError *error) {
        if (completionBlock) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completionBlock(error);
            });
        }
    };

    [self.container addOperation:operation];
}

- (void)setUserDefaultRole:(NSArray<SKYRole *> *)roles
                completion:(void (^)(NSError *error))completionBlock
{
    SKYSetUserDefaultRoleOperation *operation =
        [SKYSetUserDefaultRoleOperation operationWithRoles:roles];

    operation.setUserDefaultRoleCompletionBlock = ^(NSArray<SKYRole *> *roles, NSError *error) {
        if (completionBlock) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completionBlock(error);
            });
        }
    };

    [self.container addOperation:operation];
}

- (void)fetchRolesOfUsers:(NSArray<SKYRecord *> *)users
               completion:(void (^)(NSDictionary<NSString *, NSArray<SKYRole *> *> *,
                                    NSError *))completionBlock
{
    [self fetchRolesOfUsersWithUserIDs:[self getUserIDs:users]
                            completion:^(NSDictionary<NSString *, NSArray<NSString *> *> *userRoles,
                                         NSError *error) {
                                if (completionBlock) {
                                    if (error) {
                                        completionBlock(nil, error);
                                        return;
                                    }

                                    NSMutableDictionary<NSString *, NSArray<SKYRole *> *>
                                        *parsedUserRoles = [NSMutableDictionary dictionary];
                                    for (NSString *userID in userRoles) {
                                        NSMutableArray *roles = [NSMutableArray array];
                                        for (NSString *role in userRoles[userID]) {
                                            [roles addObject:[SKYRole roleWithName:role]];
                                        }
                                        [parsedUserRoles setObject:roles forKey:userID];
                                    }

                                    completionBlock(parsedUserRoles, nil);
                                }
                            }];
}

- (void)fetchRolesOfUsersWithUserIDs:(NSArray<NSString *> *)userIDs
                          completion:(void (^)(NSDictionary<NSString *, NSArray<NSString *> *> *,
                                               NSError *))completionBlock
{
    SKYFetchUserRoleOperation *operation = [SKYFetchUserRoleOperation operationWithUserIDs:userIDs];
    operation.fetchUserRoleCompletionBlock =
        ^(NSDictionary<NSString *, NSArray<NSString *> *> *userRoles, NSError *error) {
            if (completionBlock) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    completionBlock(userRoles, error);
                });
            }
        };

    [self.container addOperation:operation];
}

- (void)assignRoles:(NSArray<SKYRole *> *)roles
            toUsers:(NSArray<SKYRecord *> *)users
         completion:(void (^)(NSError *error))completionBlock
{
    [self assignRolesWithNames:[self getRoleNames:roles]
                toUsersWithIDs:[self getUserIDs:users]
                    completion:completionBlock];
}

- (void)assignRolesWithNames:(NSArray<NSString *> *)roleNames
              toUsersWithIDs:(NSArray<NSString *> *)userIDs
                  completion:(void (^)(NSError *error))completionBlock
{
    SKYAssignUserRoleOperation *operation =
        [SKYAssignUserRoleOperation operationWithUserIDs:userIDs roleNames:roleNames];

    operation.assignUserRoleCompletionBlock = ^(NSArray<SKYRecord *> *users, NSError *error) {
        if (completionBlock) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completionBlock(error);
            });
        }
    };

    [self.container addOperation:operation];
}

- (void)revokeRoles:(NSArray<SKYRole *> *)roles
          fromUsers:(NSArray<SKYRecord *> *)users
         completion:(void (^)(NSError *error))completionBlock
{
    [self revokeRolesWithNames:[self getRoleNames:roles]
              fromUsersWihtIDs:[self getUserIDs:users]
                    completion:completionBlock];
}

- (void)revokeRolesWithNames:(NSArray<NSString *> *)roleNames
            fromUsersWihtIDs:(NSArray<NSString *> *)userIDs
                  completion:(void (^)(NSError *error))completionBlock
{
    SKYRevokeUserRoleOperation *operation =
        [SKYRevokeUserRoleOperation operationWithUserIDs:userIDs roleNames:roleNames];

    operation.revokeUserRoleCompletionBlock = ^(NSArray<NSString *> *userIDs, NSError *error) {
        if (completionBlock) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completionBlock(error);
            });
        }
    };

    [self.container addOperation:operation];
}

- (void)adminEnableUserWithUserID:(NSString *)userID
                       completion:(void (^_Nullable)(NSString *userID,
                                                     NSError *_Nullable error))completionBlock
{
    SKYSetDisableUserOperation *operation =
        [SKYSetDisableUserOperation enableOperationWithUserID:userID];

    operation.setCompletionBlock = ^(NSString *userID, NSError *error) {
        if (completionBlock) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completionBlock(userID, error);
            });
        }
    };

    [self.container addOperation:operation];
}

- (void)adminDisableUserWithUserID:(NSString *)userID
                           message:(NSString *_Nullable)message
                            expiry:(NSDate *_Nullable)expiry
                        completion:(void (^_Nullable)(NSString *userID,
                                                      NSError *_Nullable error))completionBlock
{
    SKYSetDisableUserOperation *operation =
        [SKYSetDisableUserOperation disableOperationWithUserID:userID
                                                       message:message
                                                        expiry:expiry];

    operation.setCompletionBlock = ^(NSString *userID, NSError *error) {
        if (completionBlock) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completionBlock(userID, error);
            });
        }
    };

    [self.container addOperation:operation];
}

- (NSArray<NSString *> *)getUserIDs:(NSArray<SKYRecord *> *)users
{
    NSMutableArray<NSString *> *userIDs = [NSMutableArray arrayWithCapacity:users.count];
    for (SKYRecord *user in users) {
        if (![user.recordType isEqualToString:@"user"]) {
            @throw [NSException exceptionWithName:NSInvalidArgumentException
                                           reason:@"Record type should be user"
                                         userInfo:nil];
        }

        [userIDs addObject:user.recordID];
    }

    return userIDs;
}

- (NSArray<NSString *> *)getRoleNames:(NSArray<SKYRole *> *)roles
{
    NSMutableArray<NSString *> *roleNames = [NSMutableArray arrayWithCapacity:roles.count];
    for (SKYRole *role in roles) {
        [roleNames addObject:role.name];
    }

    return roleNames;
}

@end
