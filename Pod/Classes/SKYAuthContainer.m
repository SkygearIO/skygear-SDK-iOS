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

#import "SKYAccessToken.h"
#import "SKYContainer.h"
#import "SKYError.h"
#import "SKYQuery.h"
#import "SKYUser.h"
#import "SKYUserDiscoverPredicate.h"

#import "SKYChangePasswordOperation.h"
#import "SKYGetCurrentUserOperation.h"
#import "SKYLoginUserOperation.h"
#import "SKYLogoutUserOperation.h"
#import "SKYQueryOperation.h"
#import "SKYSignupUserOperation.h"
#import "SKYUpdateUserOperation.h"

@implementation SKYAuthContainer {
    SKYAccessToken *_accessToken;
    NSString *_userRecordID;
    SKYUser *_currentUser;
}

#pragma mark - private

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
    NSString *userRecordID =
        [[NSUserDefaults standardUserDefaults] objectForKey:@"SKYContainerCurrentUserRecordID"];
    NSString *accessToken =
        [[NSUserDefaults standardUserDefaults] objectForKey:@"SKYContainerAccessToken"];
    SKYUser *user = nil;
    NSData *encodedUser =
        [[NSUserDefaults standardUserDefaults] objectForKey:@"SKYContainerCurrentUser"];
    if ([encodedUser isKindOfClass:[NSData class]]) {
        user = [NSKeyedUnarchiver unarchiveObjectWithData:encodedUser];
    }

    if (accessToken && (userRecordID || user)) {
        _currentUser = user;
        if (user) {
            _userRecordID = user.userID;
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

- (void)performUserAuthOperation:(SKYOperation *)operation
               completionHandler:(SKYContainerUserOperationActionCompletion)completionHandler
{
    __weak typeof(self) weakSelf = self;
    void (^completionBock)(SKYUser *, SKYAccessToken *, NSError *) =
        ^(SKYUser *user, SKYAccessToken *accessToken, NSError *error) {
            if (!error) {
                [weakSelf updateWithUser:user accessToken:accessToken];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                completionHandler(user, error);
            });
        };

    if ([operation isKindOfClass:[SKYLoginUserOperation class]]) {
        [(SKYLoginUserOperation *)operation setLoginCompletionBlock:completionBock];
    } else if ([operation isKindOfClass:[SKYSignupUserOperation class]]) {
        [(SKYSignupUserOperation *)operation setSignupCompletionBlock:completionBock];
    } else if ([operation isKindOfClass:[SKYGetCurrentUserOperation class]]) {
        [(SKYGetCurrentUserOperation *)operation setGetCurrentUserCompletionBlock:completionBock];
    } else {
        @throw [NSException
            exceptionWithName:NSInvalidArgumentException
                       reason:[NSString stringWithFormat:@"Unexpected operation: %@",
                                                         NSStringFromClass(operation.class)]
                     userInfo:nil];
    }
    [self.container addOperation:operation];
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
    if (_accessToken && (_userRecordID || _currentUser)) {
        if (_userRecordID) {
            [[NSUserDefaults standardUserDefaults] setObject:_userRecordID
                                                      forKey:@"SKYContainerCurrentUserRecordID"];
        }
        if (_currentUser) {
            [[NSUserDefaults standardUserDefaults]
                setObject:[NSKeyedArchiver archivedDataWithRootObject:_currentUser]
                   forKey:@"SKYContainerCurrentUser"];
        }
        [[NSUserDefaults standardUserDefaults] setObject:_accessToken.tokenString
                                                  forKey:@"SKYContainerAccessToken"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    } else {
        [[NSUserDefaults standardUserDefaults]
            removeObjectForKey:@"SKYContainerCurrentUserRecordID"];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"SKYContainerAccessToken"];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"SKYContainerCurrentUser"];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
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

- (void)updateWithUser:(SKYUser *)user accessToken:(SKYAccessToken *)accessToken
{
    if (user && accessToken) {
        _userRecordID = user.userID;
        _accessToken = accessToken;
        _currentUser = user;
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
    [self performUserAuthOperation:operation completionHandler:completionHandler];
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
    [self performUserAuthOperation:operation completionHandler:completionHandler];
}

- (void)signupWithUsername:(NSString *)username
                  password:(NSString *)password
         completionHandler:(SKYContainerUserOperationActionCompletion)completionHandler
{
    NSDictionary *authData = @{ @"username" : username };
    SKYSignupUserOperation *operation =
        [SKYSignupUserOperation operationWithAuthData:authData password:password];
    [self performUserAuthOperation:operation completionHandler:completionHandler];
}

- (void)signupWithEmail:(NSString *)email
               password:(NSString *)password
      completionHandler:(SKYContainerUserOperationActionCompletion)completionHandler
{
    NSDictionary *authData = @{ @"email" : email };
    SKYSignupUserOperation *operation =
        [SKYSignupUserOperation operationWithAuthData:authData password:password];
    [self performUserAuthOperation:operation completionHandler:completionHandler];
}

/**
 Creates a user account with the specified username, password and profile.
 */
- (void)signupWithUsername:(NSString *)username
                  password:(NSString *)password
         profileDictionary:(NSDictionary *)profile
         completionHandler:(SKYContainerUserOperationActionCompletion)completionHandler
{
    NSDictionary *authData = @{ @"username" : username };
    SKYSignupUserOperation *operation =
        [SKYSignupUserOperation operationWithAuthData:authData password:password profile:profile];
    [self performUserAuthOperation:operation completionHandler:completionHandler];
}

/**
 Creates a user account with the specified email, password and profile.
 */
- (void)signupWithEmail:(NSString *)email
               password:(NSString *)password
      profileDictionary:(NSDictionary *)profile
      completionHandler:(SKYContainerUserOperationActionCompletion)completionHandler
{
    NSDictionary *authData = @{ @"email" : email };
    SKYSignupUserOperation *operation =
        [SKYSignupUserOperation operationWithAuthData:authData password:password profile:profile];
    [self performUserAuthOperation:operation completionHandler:completionHandler];
}

- (void)signupAnonymouslyWithCompletionHandler:
    (SKYContainerUserOperationActionCompletion)completionHandler
{
    SKYSignupUserOperation *operation = [SKYSignupUserOperation operationWithAnonymousUser];
    [self performUserAuthOperation:operation completionHandler:completionHandler];
}

- (void)loginWithUsername:(NSString *)username
                 password:(NSString *)password
        completionHandler:(SKYContainerUserOperationActionCompletion)completionHandler
{
    SKYLoginUserOperation *operation =
        [SKYLoginUserOperation operationWithUsername:username password:password];
    [self performUserAuthOperation:operation completionHandler:completionHandler];
}

- (void)loginWithEmail:(NSString *)email
              password:(NSString *)password
     completionHandler:(SKYContainerUserOperationActionCompletion)completionHandler
{
    SKYLoginUserOperation *operation =
        [SKYLoginUserOperation operationWithEmail:email password:password];
    [self performUserAuthOperation:operation completionHandler:completionHandler];
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

    operation.changePasswordCompletionBlock =
        ^(SKYUser *user, SKYAccessToken *accessToken, NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completionHandler(user, error);
            });
        };

    [self.container addOperation:operation];
}

- (void)getWhoAmIWithCompletionHandler:(SKYContainerUserOperationActionCompletion)completionHandler
{
    SKYGetCurrentUserOperation *operation = [[SKYGetCurrentUserOperation alloc] init];
    [self performUserAuthOperation:operation completionHandler:completionHandler];
}

- (void)queryUsersByEmails:(NSArray<NSString *> *)emails
         completionHandler:(void (^)(NSArray<SKYRecord *> *, NSError *))completionHandler
{
    SKYUserDiscoverPredicate *predicate = [SKYUserDiscoverPredicate predicateWithEmails:emails];
    [self queryUsersByPredicate:predicate completionHandler:completionHandler];
}

- (void)queryUsersByUsernames:(NSArray<NSString *> *)usernames
            completionHandler:(void (^)(NSArray<SKYRecord *> *, NSError *))completionHandler
{
    SKYUserDiscoverPredicate *predicate =
        [SKYUserDiscoverPredicate predicateWithUsernames:usernames];
    [self queryUsersByPredicate:predicate completionHandler:completionHandler];
}

- (void)queryUsersByPredicate:(SKYUserDiscoverPredicate *)predicate
            completionHandler:(void (^)(NSArray<SKYRecord *> *, NSError *))completionHandler
{
    SKYQuery *query = [SKYQuery queryWithRecordType:@"user" predicate:predicate];
    SKYQueryOperation *operation = [SKYQueryOperation operationWithQuery:query];
    operation.database = self.container.publicCloudDatabase;
    operation.queryRecordsCompletionBlock =
        ^(NSArray *fetchedRecords, SKYQueryCursor *cursor, NSError *operationError) {
            if (completionHandler) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    completionHandler(fetchedRecords, operationError);
                });
            }
        };

    [self.container addOperation:operation];
}

- (void)saveUser:(SKYUser *)user
      completion:(SKYContainerUserOperationActionCompletion)completionHandler
{
    SKYUpdateUserOperation *operation = [SKYUpdateUserOperation operationWithUser:user];

    operation.updateUserCompletionBlock = ^(SKYUser *user, NSError *error) {
        if (completionHandler) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completionHandler(user, error);
            });
        }
    };

    [self.container addOperation:operation];
}

@end
