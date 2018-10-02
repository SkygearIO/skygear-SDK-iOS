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

#import <SKYKit/SKYKit.h>

#import "SKYAccessControl_Private.h"
#import "SKYAuthContainer_Private.h"
#import "SKYContainer_Private.h"
#import "SKYDatabase_Private.h"
#import "SKYNotification_Private.h"
#import "SKYPubsubContainer_Private.h"
#import "SKYPushContainer_Private.h"

#import "SKYKit+version.h"

NSString *const SKYVersion = SKY_VERSION;

NSString *const SKYContainerDidChangeCurrentUserNotification =
    @"SKYContainerDidChangeCurrentUserNotification";

@implementation SKYContainer {
    SKYPublicDatabase *_publicCloudDatabase;
    SKYConfiguration *_config;

    SKYAuthContainer *_auth;
    SKYPubsubContainer *_pubsub;
    SKYPushContainer *_push;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _config = [[SKYConfiguration alloc] init];
        _defaultTimeoutInterval = 60.0;

        _operationQueue = [[NSOperationQueue alloc] init];
        _operationQueue.name = @"SKYContainerOperationQueue";

        _auth = [[SKYAuthContainer alloc] initWithContainer:self];
        _publicCloudDatabase =
            [[SKYPublicDatabase alloc] initWithContainer:self databaseID:@"_public"];
        _privateCloudDatabase = [[SKYDatabase alloc] initWithContainer:self databaseID:@"_private"];
        _pubsub = [[SKYPubsubContainer alloc] initWithContainer:self];
        _push = [[SKYPushContainer alloc] initWithContainer:self];

        [self.auth loadCurrentUserAndAccessToken];
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

- (SKYAuthContainer *)auth
{
    return _auth;
}

- (SKYPubsubContainer *)pubsub
{
    return _pubsub;
}

- (SKYPushContainer *)push
{
    return _push;
}

- (SKYPublicDatabase *)publicCloudDatabase
{
    return _publicCloudDatabase;
}

- (void)configAddress:(NSString *)address
{
    NSURL *url = [NSURL URLWithString:address];
    _config.endPointAddress = url;
    [self.pubsub configAddress:address];
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
    _config.apiKey = [APIKey copy];
    [self.pubsub configureWithAPIKey:APIKey];
}

- (void)configure:(SKYConfiguration *)config
{
    _config = config;
    [_auth setCurrentUserDataEncryptionEnable:_config.encryptCurrentUserData];
    [_auth loadCurrentUserAndAccessToken];
    [self.pubsub configAddress:config.endPointAddress.absoluteString apiKey:_config.apiKey];
}

- (void)addOperation:(SKYOperation *)operation
{
    operation.container = self;
    operation.timeoutInterval = self.defaultTimeoutInterval;
    [self.operationQueue addOperation:operation];
}

- (void)setEndPointAddress:(NSURL *)endPointAddress
{
    _config.endPointAddress = endPointAddress;
}

- (NSURL *)endPointAddress
{
    static BOOL warnedOnce;

    if (!_config.endPointAddress && !warnedOnce) {
        NSLog(
            @"Warning: Container is not configured with an endpoint address. Please call -[%@ %@].",
            NSStringFromClass([SKYContainer class]),
            NSStringFromSelector(@selector(configAddress:)));
        warnedOnce = YES;
    }
    return _config.endPointAddress;
}

- (NSString *)APIKey
{
    static BOOL warnedOnce;

    if (!_config.apiKey && !warnedOnce) {
        NSLog(@"Warning: Container is not configured with an API key. Please call -[%@ %@].",
              NSStringFromClass([SKYContainer class]),
              NSStringFromSelector(@selector(configureWithAPIKey:)));
        warnedOnce = YES;
    }
    return _config.apiKey;
}

- (void)callLambda:(NSString *)action completionHandler:(void (^)(id, NSError *))completionHandler
{
    [self callLambda:action arguments:nil completion:completionHandler];
}

- (void)callLambda:(NSString *)action
            arguments:(NSArray *)arguments
    completionHandler:(void (^)(id, NSError *))completionHandler
{
    [self callLambda:action arguments:arguments completion:completionHandler];
}

- (void)callLambda:(NSString *)action
       arrayArguments:(NSArray *)arguments
    completionHandler:(void (^)(id, NSError *))completionHandler
{
    [self callLambda:action arguments:arguments completion:completionHandler];
}

- (void)callLambda:(NSString *)action
    dictionaryArguments:(NSDictionary *)arguments
      completionHandler:(void (^)(id, NSError *))completionHandler
{
    [self callLambda:action arguments:arguments completion:completionHandler];
}

- (void)callLambda:(NSString *)action
         arguments:(id)arguments
        completion:(void (^)(id, NSError *))completion
{
    dispatch_group_t lambda_group = dispatch_group_create();
    __block NSError *lastError = nil;
    __block id presavedArguments = nil;
    dispatch_group_enter(lambda_group);
    [self.publicCloudDatabase sky_presave:arguments
                               completion:^(id _Nullable presavedObject, NSError *_Nullable error) {
                                   lastError = error;
                                   presavedArguments = presavedObject;
                                   dispatch_group_leave(lambda_group);
                               }];

    dispatch_group_notify(lambda_group, dispatch_get_main_queue(), ^{
        if (lastError) {
            if (completion) {
                completion(nil, lastError);
            }
            return;
        }

        SKYLambdaOperation *operation;
        if ([presavedArguments isKindOfClass:[NSArray class]]) {
            operation =
                [[SKYLambdaOperation alloc] initWithAction:action arrayArguments:presavedArguments];
        } else if ([presavedArguments isKindOfClass:[NSDictionary class]]) {
            operation = [[SKYLambdaOperation alloc] initWithAction:action
                                               dictionaryArguments:presavedArguments];
        } else {
            operation = [[SKYLambdaOperation alloc] initWithAction:action dictionaryArguments:@{}];
        }

        operation.lambdaCompletionBlock = ^(NSDictionary *result, NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (completion) {
                    completion(result, error);
                }
            });
        };

        [self addOperation:operation];
    });
}

@end
