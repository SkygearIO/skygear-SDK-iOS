//
//  SKYPubsubContainer.m
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

#import "SKYPubsubContainer.h"

#import "SKYContainer_Private.h"
#import "SKYPubsubContainer_Private.h"
#import "SKYPushContainer_Private.h"

NSString *const SKYContainerPubsubBaseURL = @"ws://localhost:5000/pubsub";
NSString *const SKYContainerInternalPubsubBaseURL = @"ws://localhost:5000/_/pubsub";

@implementation SKYPubsubContainer

- (instancetype)initWithContainer:(SKYContainer *)container
{
    self = [super init];
    if (self) {
        self.container = container;
        self.pubsubClient = [[SKYPubsubClient alloc]
            initWithEndPoint:[NSURL URLWithString:SKYContainerPubsubBaseURL]
                      APIKey:nil];
        self.internalPubsubClient = [[SKYPubsubClient alloc]
            initWithEndPoint:[NSURL URLWithString:SKYContainerInternalPubsubBaseURL]
                      APIKey:nil];
    }
    return self;
}

- (void)configInternalPubsubClient
{
    __weak typeof(self) weakSelf = self;

    NSString *deviceID = self.container.push.registeredDeviceID;
    if (deviceID.length) {
        [_internalPubsubClient
            subscribeTo:[NSString stringWithFormat:@"_sub_%@", deviceID]
                handler:^(NSDictionary *data) {
                    [weakSelf.container.push handleSubscriptionNoticeWithData:data];
                }];
    } else {
        __block id observer;
        observer = [[NSNotificationCenter defaultCenter]
            addObserverForName:SKYContainerDidRegisterDeviceNotification
                        object:nil
                         queue:self.container.operationQueue
                    usingBlock:^(NSNotification *note) {
                        [weakSelf configInternalPubsubClient];
                        [[NSNotificationCenter defaultCenter] removeObserver:observer];
                    }];
    }
}

#pragma mark - Pubsub client

- (void)setPubsubClient:(SKYPubsubClient *)pubsubClient
{
    _pubsubClient = pubsubClient;
    __weak typeof(self) wself = self;
    [_pubsubClient setOnOpenCallback:^{
        id<SKYPubsubContainerDelegate> delegate = wself.delegate;
        if ([delegate respondsToSelector:@selector(pubsubDidOpen:)]) {
            typeof(wself) strongSelf = wself;
            [delegate pubsubDidOpen:strongSelf];
        }
    }];
    [_pubsubClient setOnCloseCallback:^{
        id<SKYPubsubContainerDelegate> delegate = wself.delegate;
        if ([delegate respondsToSelector:@selector(pubsubDidClose:)]) {
            typeof(wself) strongSelf = wself;
            [delegate pubsubDidClose:strongSelf];
        }
    }];
    [_pubsubClient setOnErrorCallback:^(NSError *_Nonnull error) {
        id<SKYPubsubContainerDelegate> delegate = wself.delegate;
        if ([delegate respondsToSelector:@selector(pubsub:didFailWithError:)]) {
            typeof(wself) strongSelf = wself;
            [delegate pubsub:strongSelf didFailWithError:error];
        }
    }];
}

- (NSURL *)endPointAddress
{
    return self.pubsubClient.endPointAddress;
}

- (void)connect
{
    [self.pubsubClient connect];
}

- (void)close
{
    [self.pubsubClient close];
}

- (void)subscribeTo:(NSString *)channel handler:(void (^)(NSDictionary *))messageHandler
{
    [self.pubsubClient subscribeTo:channel handler:messageHandler];
}

- (void)unsubscribe:(NSString *)channel
{
    [self.pubsubClient unsubscribe:channel];
}

- (void)publishMessage:(NSDictionary *)message toChannel:(NSString *)channel
{
    [self.pubsubClient publishMessage:message toChannel:channel];
}

@end
