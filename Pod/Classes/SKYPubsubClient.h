//
//  SKYPubsubClient.h
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

NS_ASSUME_NONNULL_BEGIN

/// Undocumented
@interface SKYPubsubClient : NSObject

/// Undocumented
@property (nonatomic, copy) NSURL *_Nullable endPointAddress;
/// Undocumented
@property (nonatomic, copy) NSString *_Nullable APIKey;

/**
 In normal usage, you will not need to init the PubsubClient by yourself. You just get the
 pubsubClient from the default
 SKYContainer and call the following:

 Subscribe a channel with handler
 [[SKYContainer defaultContainer].pubsubClient subscribeTo:@"noteapp"
                                                  handler:^(NSDictionary *msg) {
                                                        NSLog(@"Got pubsub msg: %@", msg);
                                                  }];

 Unsubscribe a channel
 [[SKYContainer defaultContainer].pubsubClient publishMessage:@{@"note":@"cool"}
 toChannel:@"noteapp"];
 */
- (instancetype)initWithEndPoint:(NSURL *_Nullable)endPoint APIKey:(NSString *_Nullable)APIKey;

/**
 Manually connect to the pubsub end-point without subscribing a channel. Normally, you can just
 */
- (void)connect;
/**
 Manually close pubsub conenction and unsubscribe everthings.
 */
- (void)close;

/**
 Subscribe to channel with the messageHandler block. Each channel can only have one messageHandler.
 */
- (void)subscribeTo:(NSString *)channel handler:(void (^)(NSDictionary *))messageHandler;

/**
 Unscubscribe a channel without closing connection.
 */
- (void)unsubscribe:(NSString *)channel;

/**
 Publish message to a channel.
 */
- (void)publishMessage:(NSDictionary *)message toChannel:(NSString *)channel;

@end

NS_ASSUME_NONNULL_END
