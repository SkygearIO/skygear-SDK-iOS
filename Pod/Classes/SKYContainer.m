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
#import "SKYContainer_Private.h"
#import "SKYChangePasswordOperation.h"
#import "SKYDatabase_Private.h"
#import "SKYNotification_Private.h"
#import "SKYOperation.h"
#import "SKYPushOperation.h"
#import "SKYLoginUserOperation.h"
#import "SKYLogoutUserOperation.h"

#import "SKYSignupUserOperation.h"
#import "SKYRegisterDeviceOperation.h"
#import "SKYUploadAssetOperation.h"
#import "SKYLambdaOperation.h"

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

/**
 Configurate the End-Point IP:PORT, no scheme is required. i.e. no http://
 */
- (void)configAddress:(NSString *)address
{
    NSString *url = [NSString stringWithFormat:@"http://%@/", address];
    _endPointAddress = [NSURL URLWithString:url];
    _pubsubClient.endPointAddress =
        [NSURL URLWithString:[NSString stringWithFormat:@"ws://%@/pubsub", address]];

    _internalPubsubClient.endPointAddress =
        [NSURL URLWithString:[NSString stringWithFormat:@"ws://%@/_/pubsub", address]];
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
                [weakSelf updateWithUserRecordID:user.recordID accessToken:accessToken];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                completionHandler(user, error);
            });
        };

    if ([operation isKindOfClass:[SKYLoginUserOperation class]]) {
        [(SKYLoginUserOperation *)operation setLoginCompletionBlock:completionBock];
    } else if ([operation isKindOfClass:[SKYSignupUserOperation class]]) {
        [(SKYSignupUserOperation *)operation setSignupCompletionBlock:completionBock];
    } else {
        @throw
            [NSException exceptionWithName:NSInvalidArgumentException
                                    reason:@"Only User Login or Create User Operation is supported."
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
        [SKYSignupUserOperation operationWithEmail:username password:password];
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
    SKYUploadAssetOperation *operation = [SKYUploadAssetOperation operationWithAsset:asset];
    operation.uploadAssetCompletionBlock = completionHandler;
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

#pragma mark - SKYPushOperation

- (void)pushToUserRecordID:(NSString *)userRecordID alertBody:(NSString *)alertBody
{
    SKYPushOperation *pushOperation =
        [[SKYPushOperation alloc] initWithUserRecordIDs:@[ userRecordID ] alertBody:alertBody];
    [self addOperation:pushOperation];
}

- (void)pushToUserRecordIDs:(NSArray *)userRecordIDs alertBody:(NSString *)alertBody
{
    SKYPushOperation *pushOperation =
        [[SKYPushOperation alloc] initWithUserRecordIDs:userRecordIDs alertBody:alertBody];
    [self addOperation:pushOperation];
}

- (void)pushToUserRecordID:(NSString *)userRecordID
      alertLocalizationKey:(NSString *)alertLocalizationKey
     alertLocalizationArgs:(NSArray *)alertLocalizationArgs
{
    SKYPushOperation *pushOperation =
        [[SKYPushOperation alloc] initWithUserRecordIDs:@[ userRecordID ]
                                   alertLocalizationKey:alertLocalizationKey
                                  alertLocalizationArgs:alertLocalizationArgs];
    [self addOperation:pushOperation];
}

- (void)pushToUserRecordIDs:(NSArray *)userRecordIDs
       alertLocalizationKey:(NSString *)alertLocalizationKey
      alertLocalizationArgs:(NSArray *)alertLocalizationArgs
{
    SKYPushOperation *pushOperation =
        [[SKYPushOperation alloc] initWithUserRecordIDs:userRecordIDs
                                   alertLocalizationKey:alertLocalizationKey
                                  alertLocalizationArgs:alertLocalizationArgs];
    [self addOperation:pushOperation];
}

@end
