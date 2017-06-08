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
    SKYPublicDatabase *_publicCloudDatabase;
    NSString *_APIKey;

    SKYAuthContainer *_auth;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _endPointAddress = [NSURL URLWithString:SKYContainerRequestBaseURL];
        _operationQueue = [[NSOperationQueue alloc] init];
        _operationQueue.name = @"SKYContainerOperationQueue";
        _subscriptionSeqNumDict = [NSMutableDictionary dictionary];
        _auth = [[SKYAuthContainer alloc] initWithContainer:self];
        _publicCloudDatabase = [[SKYPublicDatabase alloc] initWithContainer:self];
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
        _defaultTimeoutInterval = 60.0;

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

- (SKYPublicDatabase *)publicCloudDatabase
{
    return _publicCloudDatabase;
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
    operation.timeoutInterval = self.defaultTimeoutInterval;
    [self.operationQueue addOperation:operation];
}

#pragma mark - SKYRemoteNotification
- (void)registerDeviceWithDeviceToken:(NSData *)deviceToken
                     existingDeviceID:(NSString *)existingDeviceID
                    completionHandler:(void (^)(NSString *, NSError *))completionHandler
{
    NSString *topic = [[NSBundle mainBundle] bundleIdentifier];
    SKYRegisterDeviceOperation *op =
        [[SKYRegisterDeviceOperation alloc] initWithDeviceToken:deviceToken topic:topic];
    op.deviceID = existingDeviceID;
    op.registerCompletionBlock = ^(NSString *deviceID, NSError *error) {
        BOOL willRetry = NO;
        if (error) {
            // If the device ID is not recognized by the server,
            // we should retry the request without the device ID.
            // Presumably the server will generate a new device ID.
            BOOL isNotFound = YES; // FIXME
            if (isNotFound && existingDeviceID) {
                [self registerDeviceWithDeviceToken:deviceToken
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
    [self registerDeviceWithDeviceToken:deviceToken completionHandler:completionHandler];
}

- (void)registerDeviceWithDeviceToken:(NSData *)deviceToken
                    completionHandler:(void (^)(NSString *, NSError *))completionHandler
{
    NSString *existingDeviceID = [self registeredDeviceID];
    [self registerDeviceWithDeviceToken:deviceToken
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
    [self registerDeviceWithDeviceToken:nil
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

- (void)unregisterDevice
{
    [self unregisterDeviceCompletionHandler:^(NSString *deviceID, NSError *error) {
        if (error != nil) {
            NSLog(@"Warning: Failed to unregister device: %@", error.localizedDescription);
            return;
        }
    }];
}

- (void)unregisterDeviceCompletionHandler:(void (^)(NSString *deviceID,
                                                    NSError *error))completionHandler
{
    NSString *existingDeviceID = self.registeredDeviceID;
    if (existingDeviceID != nil) {
        SKYUnregisterDeviceOperation *operation =
            [SKYUnregisterDeviceOperation operationWithDeviceID:existingDeviceID];
        operation.unregisterCompletionBlock = ^(NSString *deviceID, NSError *error) {
            if (completionHandler != nil) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    completionHandler(deviceID, error);
                });
            }
        };

        [self addOperation:operation];
    }
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
