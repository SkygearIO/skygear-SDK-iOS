//
//  SKYPubsubContainerTests.m
//  SKYKit
//
//  Copyright 2017 Oursky Ltd.
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
#import <OHHTTPStubs/OHHTTPStubs.h>
#import <SKYKit/SKYKit.h>

#import "SKYHexer.h"

#import "SKYPubsubContainer_Private.h"

SpecBegin(SKYPubsubContainer)

    describe(@"maintains a private pubsub", ^{
        __block SKYContainer *container = nil;
        __block id pubsub = nil;

        beforeEach(^{
            container = [[SKYContainer alloc] init];

            pubsub = OCMClassMock([SKYPubsubClient class]);
            container.pubsub.internalPubsubClient = pubsub;
        });

        afterEach(^{
            container.pubsub.internalPubsubClient = nil;
            pubsub = nil;
        });

        it(@"sets endpoint correct address", ^{
            OCMExpect([pubsub
                setEndPointAddress:[NSURL URLWithString:@"ws://newpoint.com:4321/_/pubsub"]]);

            [container configAddress:@"http://newpoint.com:4321/"];

            OCMVerifyAll(pubsub);
        });

        it(@"subscribes without deviceID", ^{
            OCMExpect([pubsub subscribeTo:@"_sub_deviceid" handler:[OCMArg any]]);

            [container configAddress:@"http://newpoint.com:4321/"];

            [[NSUserDefaults standardUserDefaults] setObject:@"deviceid"
                                                      forKey:@"SKYContainerDeviceID"];
            [[NSNotificationCenter defaultCenter]
                postNotificationName:SKYContainerDidRegisterDeviceNotification
                              object:nil];

            OCMVerifyAllWithDelay(pubsub, 100);
        });

        it(@"subscribes with deviceID", ^{
            OCMExpect([pubsub subscribeTo:@"_sub_deviceid" handler:[OCMArg any]]);

            [[NSUserDefaults standardUserDefaults] setObject:@"deviceid"
                                                      forKey:@"SKYContainerDeviceID"];
            [container configAddress:@"http://newpoint.com:4321/"];

            OCMVerifyAll(pubsub);
        });

        describe(@"subscribed with delegate", ^{
            __block id delegate = nil;
            __block void (^handler)(NSDictionary *);

            beforeEach(^{
                delegate = OCMProtocolMock(@protocol(SKYContainerDelegate));
                container.delegate = delegate;

                [[NSUserDefaults standardUserDefaults] setObject:@"deviceid"
                                                          forKey:@"SKYContainerDeviceID"];
                OCMStub([pubsub subscribeTo:@"_sub_deviceid" handler:[OCMArg any]])
                    .andDo(^(NSInvocation *invocation) {
                        void (^h)(NSDictionary *);
                        [invocation getArgument:&h atIndex:3];
                        handler = h;
                    });
                [container configAddress:@"http://newpoint.com:4321/"];
            });

            afterEach(^{
                [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"SKYContainerDeviceID"];
                delegate = nil;
            });

            it(@"sends message to delegate", ^{
                OCMExpect([delegate container:container
                       didReceiveNotification:[OCMArg checkWithBlock:^BOOL(SKYNotification *n) {
                           return [n.subscriptionID isEqualToString:@"subscriptionid"];
                       }]]);

                handler(@{
                    @"subscription-id" : @"subscriptionid",
                    @"seq-num" : @1,
                });

                OCMVerifyAll(delegate);
            });

            it(@"deduplicates message to delegate", ^{
                [delegate setExpectationOrderMatters:YES];

                OCMExpect([delegate container:container
                       didReceiveNotification:[OCMArg checkWithBlock:^BOOL(SKYNotification *n) {
                           return [n.subscriptionID isEqualToString:@"subscription0"];
                       }]]);
                OCMExpect([delegate container:container
                       didReceiveNotification:[OCMArg checkWithBlock:^BOOL(SKYNotification *n) {
                           return [n.subscriptionID isEqualToString:@"subscription1"];
                       }]]);
                OCMExpect(
                    [[delegate reject] container:[OCMArg any] didReceiveNotification:[OCMArg any]]);

                handler(@{
                    @"subscription-id" : @"subscription0",
                    @"seq-num" : @1,
                });
                handler(@{
                    @"subscription-id" : @"subscription1",
                    @"seq-num" : @2,
                });
                handler(@{
                    @"subscription-id" : @"subscription1",
                    @"seq-num" : @1,
                });

                OCMVerifyAll(delegate);
            });
        });
    });

SpecEnd
