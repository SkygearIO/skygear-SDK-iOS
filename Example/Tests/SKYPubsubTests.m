//
//  SKYPubsubTests.m
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

#import "SRWebSocket.h"
#import <SKYKit/SKYKit.h>
#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

@interface SKYPubsubClient () <SRWebSocketDelegate>
- (SRWebSocket *)makeWebSocket;
@end

SpecBegin(SKYPubsub)

    describe(@"Pubsub connection", ^{
        __block SKYPubsubClient *pubsubClient = nil;
        __block id mockPubsub = nil;
        __block id mockWS = nil;

        beforeEach(^{
            NSURL *endPoint = [NSURL URLWithString:@"ws://localhost:3000/pubsub"];
            pubsubClient = [[SKYPubsubClient alloc] initWithEndPoint:endPoint APIKey:@"APIKEY"];
            mockPubsub = [OCMockObject partialMockForObject:pubsubClient];
            mockWS = [OCMockObject mockForClass:[SRWebSocket class]];
            OCMStub([mockWS setDelegate:[OCMArg isNotNil]]);
            OCMStub([mockPubsub makeWebSocket]).andReturn(mockWS);
        });

        it(@"connect the websocket", ^{
            [[mockWS expect] open];
            [pubsubClient connect];
            [mockWS verify];
        });

        it(@"multiple connect will only have on open websocket", ^{
            [[mockWS expect] open];
            [pubsubClient connect];
            [pubsubClient connect];
            [pubsubClient connect];
            [mockWS verify];
        });

        it(@"disconnect the websocket", ^{
            [[mockWS expect] open];
            [[mockWS expect] close];
            [pubsubClient connect];
            [pubsubClient webSocketDidOpen:mockWS];
            [pubsubClient close];
            [mockWS verify];
        });

        it(@"noop if call close on not opend pubsub", ^{
            [[mockWS reject] close];
            [pubsubClient close];
        });

        it(@"auto connect the websocket on first subscribe", ^{
            [[mockWS expect] open];
            [pubsubClient subscribeTo:@"channel"
                              handler:^(NSDictionary *dict) {
                                  return;
                              }];
            [mockWS verify];
        });

        it(@"auto connect the websocket on first publish", ^{
            [[mockWS expect] open];
            [pubsubClient publishMessage:@{} toChannel:@"channel"];
            [mockWS verify];
        });

        it(@"auto re-connect the websocket disconnect", ^{
            [[mockWS expect] open];
            [pubsubClient publishMessage:@{} toChannel:@"channel"];
            [[mockWS expect] send:[OCMArg any]];
            [pubsubClient webSocketDidOpen:mockWS];
            [[mockWS expect] open];
            [pubsubClient webSocket:mockWS didFailWithError:nil];
            NSDate *afteRetry = [NSDate dateWithTimeIntervalSinceNow:1.1];
            [[NSRunLoop currentRunLoop] runUntilDate:afteRetry];
            [mockWS verify];
        });

        it(@"calls onOpen callbacks", ^{
            __block BOOL onOpenCalled = NO;
            [pubsubClient setOnOpenCallback:^{
                onOpenCalled = YES;
            }];

            [[mockWS expect] open];

            [pubsubClient webSocketDidOpen:mockWS];
            expect(onOpenCalled).to.equal(YES);
        });

        it(@"calls onClose callbacks", ^{
            __block BOOL onCloseCalled = NO;
            [pubsubClient setOnCloseCallback:^{
                onCloseCalled = YES;
            }];

            [[mockWS expect] open];
            [[mockWS expect] close];

            [pubsubClient webSocket:mockWS didCloseWithCode:0 reason:@"" wasClean:NO];
            expect(onCloseCalled).to.equal(YES);
        });

        it(@"calls onError callbacks", ^{
            __block NSError *onErrorCalledWithError = nil;
            [pubsubClient setOnErrorCallback:^(NSError *error) {
                onErrorCalledWithError = error;
            }];

            NSError *errorOnInvocation = [[NSError alloc] initWithDomain:@"io.skygear.test" code:0 userInfo:nil];
            [pubsubClient webSocket:mockWS didFailWithError:errorOnInvocation];
            expect(onErrorCalledWithError).to.equal(errorOnInvocation);
        });

        afterEach(^{
            [mockPubsub stopMocking];
            [mockWS stopMocking];
        });
    });

describe(@"Pubsub message", ^{
    __block SKYPubsubClient *pubsubClient = nil;
    __block id mockPubsub = nil;
    __block id mockWS = nil;

    beforeEach(^{
        NSURL *endPoint = [NSURL URLWithString:@"ws://localhost:3000/pubsub"];
        pubsubClient = [[SKYPubsubClient alloc] initWithEndPoint:endPoint APIKey:@"APIKEY"];
        mockPubsub = [OCMockObject partialMockForObject:pubsubClient];
        mockWS = [OCMockObject mockForClass:[SRWebSocket class]];
        OCMStub([mockWS setDelegate:[OCMArg isNotNil]]);
        OCMStub([mockPubsub makeWebSocket]).andReturn(mockWS);
        [[mockWS expect] open];
        [pubsubClient connect];
        [pubsubClient webSocketDidOpen:mockWS];
    });

    it(@"publish message", ^{
        [[mockWS expect] send:[OCMArg checkWithBlock:^BOOL(id value) {
                             NSData *objectData = [value dataUsingEncoding:NSUTF8StringEncoding];
                             NSError *error;
                             NSDictionary *jsonData =
                                 [NSJSONSerialization JSONObjectWithData:objectData options:0 error:&error];
                             expect(jsonData[@"channel"]).to.equal(@"channel");
                             expect(jsonData[@"action"]).to.equal(@"pub");
                             return true;
                         }]];
        [pubsubClient publishMessage:@{} toChannel:@"channel"];
        [mockWS verify];
    });

    it(@"subscribe channel", ^{
        [[mockWS expect] send:[OCMArg checkWithBlock:^BOOL(id value) {
                             NSData *objectData = [value dataUsingEncoding:NSUTF8StringEncoding];
                             NSError *error;
                             NSDictionary *jsonData =
                                 [NSJSONSerialization JSONObjectWithData:objectData options:0 error:&error];
                             expect(jsonData[@"channel"]).to.equal(@"channel");
                             expect(jsonData[@"action"]).to.equal(@"sub");
                             return true;
                         }]];
        [pubsubClient subscribeTo:@"channel"
                          handler:^(NSDictionary *dict) {
                              return;
                          }];
        [mockWS verify];
    });

    afterEach(^{
        [mockPubsub stopMocking];
        [mockWS stopMocking];
    });
});

SpecEnd
