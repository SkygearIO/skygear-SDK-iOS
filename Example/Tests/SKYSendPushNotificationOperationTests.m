//
//  SKYSendPushNotificationOperationTests.m
//  SkyKit
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

#import <Foundation/Foundation.h>
#import <SkyKit/SkyKit.h>
#import <OHHTTPStubs/OHHTTPStubs.h>
#import "SKYNotificationInfo.h"

SpecBegin(SKYSendPushNotificationOperation)

    describe(@"send push", ^{
        __block SKYContainer *container = nil;
        SKYAPSNotificationInfo *apsNotificationInfo = [SKYAPSNotificationInfo notificationInfo];
        apsNotificationInfo.alertBody = @"Hello World!";

        SKYNotificationInfo *notificationInfo = [SKYNotificationInfo notificationInfo];
        notificationInfo.apsNotificationInfo = apsNotificationInfo;

        NSDictionary *expectedNotificationPayload = @{
            @"apns" : @{
                @"aps" : @{
                    @"alert" : @{@"body" : @"Hello World!"},
                },
            },
        };

        beforeEach(^{
            container = [[SKYContainer alloc] init];
            [container updateWithUserRecordID:[SKYUserRecordID recordIDWithUsername:@"USER_ID"]
                                  accessToken:[[SKYAccessToken alloc]
                                                  initWithTokenString:@"ACCESS_TOKEN"]];
        });

        it(@"send to device", ^{
            SKYSendPushNotificationOperation *operation =
                [SKYSendPushNotificationOperation operationWithNotificationInfo:notificationInfo
                                                                deviceIDsToSend:@[ @"johndoe" ]];
            operation.container = container;
            [operation prepareForRequest];

            SKYRequest *request = operation.request;
            expect([request class]).to.beSubclassOf([SKYRequest class]);
            expect(request.APIKey).to.equal(container.APIKey);
            expect(request.action).to.equal(@"push:device");
            expect(request.payload)
                .to.equal(@{
                    @"device_ids" : @[ @"johndoe" ],
                    @"notification" : expectedNotificationPayload,
                });
        });

        it(@"send to user", ^{
            SKYSendPushNotificationOperation *operation =
                [SKYSendPushNotificationOperation operationWithNotificationInfo:notificationInfo
                                                                  userIDsToSend:@[ @"johndoe" ]];
            operation.container = container;
            [operation prepareForRequest];

            SKYRequest *request = operation.request;
            expect([request class]).to.beSubclassOf([SKYRequest class]);
            expect(request.APIKey).to.equal(container.APIKey);
            expect(request.action).to.equal(@"push:user");
            expect(request.payload)
                .to.equal(@{
                    @"user_ids" : @[ @"johndoe" ],
                    @"notification" : expectedNotificationPayload,
                });
        });

        it(@"send multiple", ^{
            SKYSendPushNotificationOperation *operation = [SKYSendPushNotificationOperation
                operationWithNotificationInfo:notificationInfo
                                userIDsToSend:@[ @"johndoe", @"janedoe" ]];
            operation.container = container;
            [operation prepareForRequest];

            SKYRequest *request = operation.request;
            expect([request class]).to.beSubclassOf([SKYRequest class]);
            expect(request.APIKey).to.equal(container.APIKey);
            expect(request.action).to.equal(@"push:user");
            expect(request.payload)
                .to.equal(@{
                    @"user_ids" : @[ @"johndoe", @"janedoe" ],
                    @"notification" : expectedNotificationPayload,
                });
        });

        it(@"make request", ^{
            SKYSendPushNotificationOperation *operation = [SKYSendPushNotificationOperation
                operationWithNotificationInfo:notificationInfo
                                userIDsToSend:@[ @"johndoe", @"janedoe" ]];
            operation.container = container;

            [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
                return YES;
            }
                withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
                    NSDictionary *parameters = @{
                        @"request_id" : @"REQUEST_ID",
                        @"result" : @[
                            @{
                               @"_id" : @"johndoe",
                            },
                            @{
                               @"_id" : @"janedoe",
                               @"_type" : @"error",
                            },
                        ]
                    };
                    NSData *payload =
                        [NSJSONSerialization dataWithJSONObject:parameters options:0 error:nil];

                    return
                        [OHHTTPStubsResponse responseWithData:payload statusCode:200 headers:@{}];
                }];

            waitUntil(^(DoneCallback done) {
                __block NSMutableArray *processedIDs = [NSMutableArray array];
                operation.perSendCompletionHandler = ^(NSString *stringID, NSError *error) {
                    [processedIDs addObject:stringID];
                    if ([stringID isEqualToString:@"johndoe"]) {
                        expect(error).to.beNil();
                    } else if ([stringID isEqualToString:@"janedoe"]) {
                        expect([error class]).to.beSubclassOf([NSError class]);
                    }
                };
                operation.sendCompletionHandler = ^(NSArray *stringIDs, NSError *error) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        expect(stringIDs).to.equal(@[ @"johndoe" ]);
                        expect(processedIDs).to.equal(@[ @"johndoe", @"janedoe" ]);
                        expect([error class]).to.beSubclassOf([NSError class]);
                        expect(error.code).to.equal(@(SKYErrorPartialFailure));
                        done();
                    });
                };

                [container addOperation:operation];
            });
        });

        it(@"pass error", ^{
            SKYSendPushNotificationOperation *operation = [SKYSendPushNotificationOperation
                operationWithNotificationInfo:notificationInfo
                                userIDsToSend:@[ @"johndoe", @"janedoe" ]];
            operation.container = container;
            [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
                return YES;
            }
                withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
                    return [OHHTTPStubsResponse
                        responseWithError:[NSError errorWithDomain:NSURLErrorDomain
                                                              code:0
                                                          userInfo:nil]];
                }];

            waitUntil(^(DoneCallback done) {
                operation.sendCompletionHandler = ^(NSArray *stringIDs, NSError *operationError) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        expect(operationError).toNot.beNil();
                        done();
                    });
                };
                [container addOperation:operation];
            });
        });

        afterEach(^{
            [OHHTTPStubs removeAllStubs];
        });
    });

SpecEnd
