//
//  SKYPubsub.h
//  Pods
//
//  Created by Rick Mak on 19/8/15.
//
//

#import <Foundation/Foundation.h>

@interface SKYPubsub : NSObject

@property (nonatomic, copy) NSURL *endPointAddress;
@property (nonatomic, copy) NSString *APIKey;

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
- (instancetype)initWithEndPoint:(NSURL *)endPoint APIKey:(NSString *)APIKey;

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
