//
//  SKYPushContainer.m
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

#import "SKYPushContainer.h"

#import "SKYContainer.h"
#import "SKYNotification_Private.h"
#import "SKYPushContainer_Private.h"

#import "SKYRegisterDeviceOperation.h"
#import "SKYUnregisterDeviceOperation.h"

NSString *const SKYContainerDidRegisterDeviceNotification =
    @"SKYContainerDidRegisterDeviceNotification";

@interface SKYPushContainer ()

@property (nonatomic, readonly) NSMutableDictionary *subscriptionSeqNumDict;

@end

@implementation SKYPushContainer

- (instancetype)initWithContainer:(SKYContainer *)container
{
    self = [super init];
    if (self) {
        self.container = container;

        _subscriptionSeqNumDict = [NSMutableDictionary dictionary];
    }
    return self;
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
                      object:self.container];
}

- (void)applicationDidReceiveRemoteNotification:(NSDictionary *)info
{
    NSDictionary *data = info[@"_ourd"];
    if (data) {
        [self handleSubscriptionNoticeWithData:data];
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
    id<SKYContainerDelegate> delegate = self.container.delegate;
    if ([delegate respondsToSelector:@selector(container:didReceiveNotification:)]) {
        [delegate container:self.container didReceiveNotification:notification];
    }
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
    [self.container addOperation:op];
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

        [self.container addOperation:operation];
    }
}

@end
