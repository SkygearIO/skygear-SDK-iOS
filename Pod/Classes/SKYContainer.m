//
//  SKYContainer.m
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

#import "SKYContainer.h"
#import "SKYAccessControl_Private.h"
#import "SKYChangePasswordOperation.h"
#import "SKYContainer_Private.h"
#import "SKYDatabase_Private.h"
#import "SKYLoginUserOperation.h"
#import "SKYLogoutUserOperation.h"
#import "SKYNotification_Private.h"
#import "SKYOperation.h"

#import "SKYDefineAdminRolesOperation.h"
#import "SKYLambdaOperation.h"
#import "SKYRegisterDeviceOperation.h"
#import "SKYSetUserDefaultRoleOperation.h"
#import "SKYSignupUserOperation.h"
#import "SKYUploadAssetOperation.h"

NSString *const SKYContainerRequestBaseURL = @"http://localhost:5000/v1";
NSString *const SKYContainerPubsubBaseURL = @"ws://localhost:5000/pubsub";
NSString *const SKYContainerInternalPubsubBaseURL = @"ws://localhost:5000/_/pubsub";

NSString *const SKYContainerDidChangeCurrentUserNotification =
    @"SKYContainerDidChangeCurrentUserNotification";
NSString *const SKYContainerDidRegisterDeviceNotification =
    @"SKYContainerDidRegisterDeviceNotification";

@interface SKYContainer ()

@property (nonatomic, readonly) NSOperationQueue *operationQueue;
@property (nonatomic, readonly) NSMutableDictionary *subscriptionSeqNumDict;

@end

@implementation SKYContainer {
    SKYAccessToken *_accessToken;
    NSString *_userRecordID;
    SKYDatabase *_publicCloudDatabase;
    NSString *_APIKey;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _endPointAddress = [NSURL URLWithString:SKYContainerRequestBaseURL];
        _operationQueue = [[NSOperationQueue alloc] init];
        _operationQueue.name = @"SKYContainerOperationQueue";
        _subscriptionSeqNumDict = [NSMutableDictionary dictionary];
        _publicCloudDatabase = [[SKYDatabase alloc] initWithContainer:self];
        _publicCloudDatabase.databaseID = @"_public";
        _privateCloudDatabase = [[SKYDatabase alloc] initWithContainer:self];
        _privateCloudDatabase.databaseID = @"_private";
        _defaultAccessControl = [SKYAccessControl defaultAccessControl];
        _APIKey = nil;
        _pubsubClient =
            [[SKYPubsub alloc] initWithEndPoint:[NSURL URLWithString:SKYContainerPubsubBaseURL]
                                         APIKey:nil];
        _internalPubsubClient = [[SKYPubsub alloc]
            initWithEndPoint:[NSURL URLWithString:SKYContainerInternalPubsubBaseURL]
                      APIKey:nil];

        [self loadAccessCurrentUserRecordIDAndAccessToken];
    }
    return self;
}

+ (SKYContainer *)defaultContainer
{
    static dispatch_once_t onceToken;
    static SKYContainer *SKYContainerDefaultInstance;
    dispatch_once(&onceToken, ^{
        SKYContainerDefaultInstance = [[SKYContainer alloc] init];
    });
    return SKYContainerDefaultInstance;
}

- (SKYDatabase *)publicCloudDatabase
{
    return _publicCloudDatabase;
}

- (NSString *)currentUserRecordID
{
    return _userRecordID;
}

- (NSString *)registeredDeviceID
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"SKYContainerDeviceID"];
}

- (void)setRegisteredDeviceID:(NSString *)deviceID
{
    if (deviceID) {
        [[NSUserDefaults standardUserDefaults] setObject:deviceID forKey:@"SKYContainerDeviceID"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }

    [[NSNotificationCenter defaultCenter]
        postNotificationName:SKYContainerDidRegisterDeviceNotification
                      object:self];
}

- (void)configAddress:(NSString *)address
{
    NSURL *url = [NSURL URLWithString:address];
    NSString *schema = url.scheme;
    if (![schema isEqualToString:@"http"] && ![schema isEqualToString:@"https"]) {
        NSLog(@"Error: only http or https schema is accepted");
        return;
    }

    NSString *host = url.host;
    if (url.port) {
        host = [host stringByAppendingFormat:@":%@", url.port];
    }

    NSString *webSocketSchema = [schema isEqualToString:@"https"] ? @"wss" : @"ws";

    _endPointAddress = url;
    _pubsubClient.endPointAddress =
        [[NSURL alloc] initWithScheme:webSocketSchema host:host path:@"/pubsub"];
    _internalPubsubClient.endPointAddress =
        [[NSURL alloc] initWithScheme:webSocketSchema host:host path:@"/_/pubsub"];
    [self configInternalPubsubClient];
}

- (void)configInternalPubsubClient
{
    __weak typeof(self) weakSelf = self;

    NSString *deviceID = self.registeredDeviceID;
    if (deviceID.length) {
        [_internalPubsubClient subscribeTo:[NSString stringWithFormat:@"_sub_%@", deviceID]
                                   handler:^(NSDictionary *data) {
                                       [weakSelf handleSubscriptionNoticeWithData:data];
                                   }];
    } else {
        __block id observer;
        observer = [[NSNotificationCenter defaultCenter]
            addObserverForName:SKYContainerDidRegisterDeviceNotification
                        object:nil
                         queue:self.operationQueue
                    usingBlock:^(NSNotification *note) {
                        [weakSelf configInternalPubsubClient];
                        [[NSNotificationCenter defaultCenter] removeObserver:observer];
                    }];
    }
}

- (void)handleSubscriptionNoticeWithData:(NSDictionary *)data
{
    NSString *subscriptionID = data[@"subscription-id"];
    NSNumber *seqNum = data[@"seq-num"];
    if (subscriptionID.length && seqNum) {
        [self handleSubscriptionNoticeWithSubscriptionID:subscriptionID seqenceNumber:seqNum];
    }
}

- (void)handleSubscriptionNoticeWithSubscriptionID:(NSString *)subscriptionID
                                     seqenceNumber:(NSNumber *)seqNum
{
    NSMutableDictionary *dict = self.subscriptionSeqNumDict;
    NSNumber *lastSeqNum = dict[subscriptionID];
    if (seqNum.unsignedLongLongValue > lastSeqNum.unsignedLongLongValue) {
        dict[subscriptionID] = seqNum;
        [self handleSubscriptionNotification:[[SKYNotification alloc]
                                                 initWithSubscriptionID:subscriptionID]];
    }
}

- (void)handleSubscriptionNotification:(SKYNotification *)notification
{
    id<SKYContainerDelegate> delegate = self.delegate;
    if ([delegate respondsToSelector:@selector(container:didReceiveNotification:)]) {
        [delegate container:self didReceiveNotification:notification];
    }
}

- (void)configureWithAPIKey:(NSString *)APIKey
{
    if (APIKey != nil && ![APIKey isKindOfClass:[NSString class]]) {
        @throw [NSException
            exceptionWithName:NSInvalidArgumentException
                       reason:[NSString stringWithFormat:
                                            @"APIKey must be a subclass of NSString. %@ given.",
                                            NSStringFromClass([APIKey class])]
                     userInfo:nil];
    }
    [self willChangeValueForKey:@"applicationIdentifier"];
    _APIKey = [APIKey copy];
    [self didChangeValueForKey:@"applicationIdentifier"];

    _pubsubClient.APIKey = _APIKey;
    _internalPubsubClient.APIKey = _APIKey;
}

- (void)applicationDidReceiveRemoteNotification:(NSDictionary *)info
{
    NSDictionary *data = info[@"_ourd"];
    if (data) {
        [self handleSubscriptionNoticeWithData:data];
    }
}

- (void)addOperation:(SKYOperation *)operation
{
    operation.container = self;
    [self.operationQueue addOperation:operation];
}

- (SKYAccessToken *)currentAccessToken
{
    return _accessToken;
}

- (void)setDefaultAccessControl:(SKYAccessControl *)defaultAccessControl
{
    _defaultAccessControl = defaultAccessControl;
    if (!_defaultAccessControl) {
        _defaultAccessControl = [SKYAccessControl publicReadableAccessControl];
    }

    [SKYAccessControl setDefaultAccessControl:_defaultAccessControl];
}

- (void)loadAccessCurrentUserRecordIDAndAccessToken
{
    NSString *userRecordID =
        [[NSUserDefaults standardUserDefaults] objectForKey:@"SKYContainerCurrentUserRecordID"];
    NSString *accessToken =
        [[NSUserDefaults standardUserDefaults] objectForKey:@"SKYContainerAccessToken"];
    if (userRecordID && accessToken) {
        _userRecordID = userRecordID;
        _accessToken = [[SKYAccessToken alloc] initWithTokenString:accessToken];
    }
}

- (void)updateWithUserRecordID:(NSString *)userRecordID accessToken:(SKYAccessToken *)accessToken
{
    BOOL userRecordIDChanged =
        !([_userRecordID isEqual:userRecordID] || (_userRecordID == nil && userRecordID == nil));
    _userRecordID = userRecordID;
    _accessToken = accessToken;

    if (userRecordID && accessToken) {
        [[NSUserDefaults standardUserDefaults] setObject:userRecordID
                                                  forKey:@"SKYContainerCurrentUserRecordID"];
        [[NSUserDefaults standardUserDefaults] setObject:accessToken.tokenString
                                                  forKey:@"SKYContainerAccessToken"];
    } else {
        [[NSUserDefaults standardUserDefaults]
            removeObjectForKey:@"SKYContainerCurrentUserRecordID"];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"SKYContainerAccessToken"];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];

    if (userRecordIDChanged) {
        [[NSNotificationCenter defaultCenter]
            postNotificationName:SKYContainerDidChangeCurrentUserNotification
                          object:self
                        userInfo:nil];
    }
}

- (void)setAuthenticationErrorHandler:(void (^)(SKYContainer *container, SKYAccessToken *token,
                                                NSError *error))authErrorHandler
{
    _authErrorHandler = authErrorHandler;
}

#pragma mark - User Auth

- (void)performUserAuthOperation:(SKYOperation *)operation
               completionHandler:(SKYContainerUserOperationActionCompletion)completionHandler
{
    __weak typeof(self) weakSelf = self;
    void (^completionBock)(SKYUser *, SKYAccessToken *, NSError *) =
        ^(SKYUser *user, SKYAccessToken *accessToken, NSError *error) {
            if (!error) {
                [weakSelf updateWithUserRecordID:user.userID accessToken:accessToken];
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
    operation.container = self;
    [_operationQueue addOperation:operation];
}

- (void)signupWithUsername:(NSString *)username
                  password:(NSString *)password
         completionHandler:(SKYContainerUserOperationActionCompletion)completionHandler
{
    SKYSignupUserOperation *operation =
        [SKYSignupUserOperation operationWithUsername:username password:password];
    [self performUserAuthOperation:operation completionHandler:completionHandler];
}

- (void)signupWithEmail:(NSString *)email
               password:(NSString *)password
      completionHandler:(SKYContainerUserOperationActionCompletion)completionHandler
{
    SKYSignupUserOperation *operation =
        [SKYSignupUserOperation operationWithEmail:email password:password];
    [self performUserAuthOperation:operation completionHandler:completionHandler];
}

- (void)signupAnonymouslyWithCompletionHandler:
    (SKYContainerUserOperationActionCompletion)completionHandler
{
    SKYSignupUserOperation *operation =
        [SKYSignupUserOperation operationWithAnonymousUserAndPassword:@"CHANGEME"];
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
    SKYLogoutUserOperation *operation = [[SKYLogoutUserOperation alloc] init];
    operation.container = self;

    __weak typeof(self) weakSelf = self;
    operation.logoutCompletionBlock = ^(NSError *error) {
        if (!error) {
            [weakSelf updateWithUserRecordID:nil accessToken:nil];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            completionHandler(nil, error);
        });
    };

    [_operationQueue addOperation:operation];
}

- (void)setNewPassword:(NSString *)newPassword
           oldPassword:(NSString *)oldPassword
     completionHandler:(SKYContainerUserOperationActionCompletion)completionHandler
{
    SKYChangePasswordOperation *operation =
        [SKYChangePasswordOperation operationWithOldPassword:oldPassword passwordToSet:newPassword];
    operation.container = self;

    operation.changePasswordCompletionBlock =
        ^(SKYUser *user, SKYAccessToken *accessToken, NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completionHandler(user, error);
            });
        };

    [_operationQueue addOperation:operation];
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
    operation.container = self;
    operation.database = self.publicCloudDatabase;
    operation.queryRecordsCompletionBlock =
        ^(NSArray *fetchedRecords, SKYQueryCursor *cursor, NSError *operationError) {
            if (completionHandler) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    completionHandler(fetchedRecords, operationError);
                });
            }
        };

    [_operationQueue addOperation:operation];
}

- (void)saveUser:(SKYUser *)user
      completion:(SKYContainerUserOperationActionCompletion)completionHandler
{
    SKYUpdateUserOperation *operation = [SKYUpdateUserOperation operationWithUser:user];
    operation.container = self;

    operation.updateUserCompletionBlock = ^(SKYUser *user, NSError *error) {
        if (completionHandler) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completionHandler(user, error);
            });
        }
    };

    [_operationQueue addOperation:operation];
}

#pragma mark - SKYRole
- (void)defineAdminRoles:(NSArray<SKYRole *> *)roles
              completion:(void (^)(NSError *error))completionBlock
{
    SKYDefineAdminRolesOperation *operation =
        [SKYDefineAdminRolesOperation operationWithRoles:roles];
    operation.container = self;

    operation.defineAdminRolesCompletionBlock = ^(NSArray<SKYRole *> *roles, NSError *error) {
        if (completionBlock) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completionBlock(error);
            });
        }
    };

    [_operationQueue addOperation:operation];
}

- (void)setUserDefaultRole:(NSArray<SKYRole *> *)roles
                completion:(void (^)(NSError *error))completionBlock
{
    SKYSetUserDefaultRoleOperation *operation =
        [SKYSetUserDefaultRoleOperation operationWithRoles:roles];
    operation.container = self;

    operation.setUserDefaultRoleCompletionBlock = ^(NSArray<SKYRole *> *roles, NSError *error) {
        if (completionBlock) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completionBlock(error);
            });
        }
    };

    [_operationQueue addOperation:operation];
}

- (void)defineCreationAccessWithRecordType:(NSString *)recordType
                                     roles:(NSArray<SKYRole *> *)roles
                                completion:(void (^)(NSError *error))completionBlock
{
    SKYDefineCreationAccessOperation *operation =
        [SKYDefineCreationAccessOperation operationWithRecordType:recordType roles:roles];
    operation.container = self;
    operation.defineCreationAccessCompletionBlock =
        ^(NSString *recordType, NSArray<SKYRole *> *roles, NSError *error) {
            if (completionBlock) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    completionBlock(error);
                });
            }
        };

    [_operationQueue addOperation:operation];
}

#pragma mark - SKYRemoteNotification
- (void)registerRemoteNotificationDeviceToken:(NSData *)deviceToken
                             existingDeviceID:(NSString *)existingDeviceID
                            completionHandler:(void (^)(NSString *, NSError *))completionHandler
{
    SKYRegisterDeviceOperation *op =
        [[SKYRegisterDeviceOperation alloc] initWithDeviceToken:deviceToken];
    op.deviceID = existingDeviceID;
    op.registerCompletionBlock = ^(NSString *deviceID, NSError *error) {
        BOOL willRetry = NO;
        if (error) {
            // If the device ID is not recognized by the server,
            // we should retry the request without the device ID.
            // Presumably the server will generate a new device ID.
            BOOL isNotFound = YES; // FIXME
            if (isNotFound && existingDeviceID) {
                [self registerRemoteNotificationDeviceToken:deviceToken
                                           existingDeviceID:nil
                                          completionHandler:completionHandler];
                willRetry = YES;
            }
        }

        if (!willRetry) {
            if (completionHandler) {
                completionHandler(deviceID, error);
            }
        }
    };
    [self addOperation:op];
}

- (void)registerRemoteNotificationDeviceToken:(NSData *)deviceToken
                            completionHandler:(void (^)(NSString *, NSError *))completionHandler
{
    NSString *existingDeviceID = [self registeredDeviceID];
    [self registerRemoteNotificationDeviceToken:deviceToken
                               existingDeviceID:existingDeviceID
                              completionHandler:^(NSString *deviceID, NSError *error) {
                                  if (!error) {
                                      [self setRegisteredDeviceID:deviceID];
                                  }

                                  if (completionHandler) {
                                      completionHandler(deviceID, error);
                                  }
                              }];
}

- (void)registerDeviceCompletionHandler:(void (^)(NSString *, NSError *))completionHandler
{
    NSString *existingDeviceID = [self registeredDeviceID];
    [self registerRemoteNotificationDeviceToken:nil
                               existingDeviceID:existingDeviceID
                              completionHandler:^(NSString *deviceID, NSError *error) {
                                  if (!error) {
                                      [self setRegisteredDeviceID:deviceID];
                                  }

                                  if (completionHandler) {
                                      completionHandler(deviceID, error);
                                  }
                              }];
}

- (void)uploadAsset:(SKYAsset *)asset
    completionHandler:(void (^)(SKYAsset *, NSError *))completionHandler
{
    __weak typeof(self) wself = self;

    SKYGetAssetPostRequestOperation *operation =
        [SKYGetAssetPostRequestOperation operationWithAsset:asset];
    operation.getAssetPostRequestCompletionBlock = ^(
        SKYAsset *asset, NSURL *postURL, NSDictionary<NSString *, NSObject *> *extraFields,
        NSError *operationError) {
        if (operationError) {
            if (completionHandler) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    completionHandler(asset, operationError);
                });
            }

            return;
        }

        SKYPostAssetOperation *postOperation =
            [SKYPostAssetOperation operationWithAsset:asset url:postURL extraFields:extraFields];
        postOperation.postAssetCompletionBlock = ^(SKYAsset *asset, NSError *postOperationError) {
            if (completionHandler) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    completionHandler(asset, postOperationError);
                });
            }
        };

        [wself addOperation:postOperation];
    };

    [self addOperation:operation];
}

- (NSString *)APIKey
{
    static BOOL warnedOnce;

    if (!_APIKey && !warnedOnce) {
        NSLog(@"Warning: Container is not configured with an API key. Please call -[%@ %@].",
              NSStringFromClass([SKYContainer class]),
              NSStringFromSelector(@selector(configureWithAPIKey:)));
        warnedOnce = YES;
    }
    return _APIKey;
}

- (void)callLambda:(NSString *)action
    completionHandler:(void (^)(NSDictionary *, NSError *))completionHandler
{
    [self callLambda:action arguments:nil completionHandler:completionHandler];
}

- (void)callLambda:(NSString *)action
            arguments:(NSArray *)arguments
    completionHandler:(void (^)(NSDictionary *, NSError *))completionHandler
{
    arguments = arguments ? arguments : @[];
    SKYLambdaOperation *operation =
        [[SKYLambdaOperation alloc] initWithAction:action arrayArguments:arguments];

    operation.lambdaCompletionBlock = ^(NSDictionary *result, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completionHandler) {
                completionHandler(result, error);
            }
        });
    };

    [self addOperation:operation];
}

@end
