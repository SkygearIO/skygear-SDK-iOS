//
//  SKYPushContainerTests.m
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

#import "SKYPushContainer_Private.h"

SpecBegin(SKYPushContainer)

    describe(@"register device", ^{
        __block id notificationObserver = nil;
        __block SKYContainer *container = nil;
        __block bool notificationPosted = NO;

        beforeEach(^{
            container = [SKYContainer testContainer];
            notificationObserver =
                [[NSNotificationCenter defaultCenter] addObserverForName:SKYContainerDidRegisterDeviceNotification
                                                                  object:container
                                                                   queue:[NSOperationQueue mainQueue]
                                                              usingBlock:^(NSNotification *note) {
                                                                  notificationPosted = YES;
                                                              }];
        });

        it(@"new device", ^{
            [OHHTTPStubs
                stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
                    return YES;
                }
                withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
                    NSDictionary *parameters = @{
                        @"request_id" : @"REQUEST_ID",
                        @"result" : @{@"id" : @"DEVICE_ID"},
                    };
                    NSData *payload = [NSJSONSerialization dataWithJSONObject:parameters options:0 error:nil];

                    return [OHHTTPStubsResponse responseWithData:payload statusCode:200 headers:@{}];
                }];

            waitUntil(^(DoneCallback done) {
                [container.push registerDeviceWithDeviceToken:[SKYHexer dataWithHexString:@"abcdef1234567890"]
                                            completionHandler:^(NSString *deviceID, NSError *error) {
                                                expect(deviceID).to.equal(@"DEVICE_ID");
                                                expect([container.push registeredDeviceID]).to.equal(@"DEVICE_ID");
                                                expect(notificationPosted).to.beTruthy();
                                                done();
                                            }];
            });
        });

        it(@"new device without device token", ^{
            [OHHTTPStubs
                stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
                    return YES;
                }
                withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
                    NSDictionary *parameters = @{
                        @"request_id" : @"REQUEST_ID",
                        @"result" : @{@"id" : @"DEVICE_ID"},
                    };
                    NSData *payload = [NSJSONSerialization dataWithJSONObject:parameters options:0 error:nil];

                    return [OHHTTPStubsResponse responseWithData:payload statusCode:200 headers:@{}];
                }];

            waitUntil(^(DoneCallback done) {
                [container.push registerDeviceCompletionHandler:^(NSString *deviceID, NSError *error) {
                    expect(deviceID).to.equal(@"DEVICE_ID");
                    expect([container.push registeredDeviceID]).to.equal(@"DEVICE_ID");
                    expect(notificationPosted).to.beTruthy();
                    done();
                }];
            });
        });

        afterEach(^{
            [OHHTTPStubs removeAllStubs];

            NSString *appDomain = [[NSBundle mainBundle] bundleIdentifier];
            [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:appDomain];

            [[NSNotificationCenter defaultCenter] removeObserver:notificationObserver];
            container = nil;
            notificationPosted = NO;
        });
    });

describe(@"unregister device", ^{
    __block SKYContainer *container = nil;

    beforeAll(^{
        NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
        [userDefault setObject:@"device_id_001" forKey:@"SKYContainerDeviceID"];
        [userDefault synchronize];
    });

    afterAll(^{
        NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
        [userDefault removeObjectForKey:@"SKYContainerDeviceID"];
        [userDefault synchronize];
    });

    beforeEach(^{
        container = [SKYContainer testContainer];
        [container.auth updateWithUserRecordID:@"user_id_001"
                                   accessToken:[[SKYAccessToken alloc] initWithTokenString:@"access_token"]];
    });

    afterEach(^{
        container = nil;
        [OHHTTPStubs removeAllStubs];
    });

    it(@"handles response correctly", ^{
        [OHHTTPStubs
            stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
                return YES;
            }
            withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
                NSDictionary *payloadDict = @{@"result" : @{@"id" : @"device_id_001"}};
                NSData *payloadData = [NSJSONSerialization dataWithJSONObject:payloadDict options:0 error:nil];
                return [OHHTTPStubsResponse responseWithData:payloadData statusCode:200 headers:@{}];
            }];

        waitUntil(^(DoneCallback done) {
            [container.push unregisterDeviceCompletionHandler:^(NSString *deviceID, NSError *error) {
                expect(deviceID).to.equal(@"device_id_001");
                expect(error).to.beNil();
                done();
            }];
        });
    });

    it(@"handles error correctly", ^{
        [OHHTTPStubs
            stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
                return YES;
            }
            withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
                NSDictionary *payloadDict =
                    @{@"error" : @{@"name" : @"ResourceNotFound", @"code" : @110, @"message" : @"device not found"}};
                NSData *payloadData = [NSJSONSerialization dataWithJSONObject:payloadDict options:0 error:nil];
                return [OHHTTPStubsResponse responseWithData:payloadData statusCode:400 headers:@{}];
            }];

        waitUntil(^(DoneCallback done) {
            [container.push unregisterDeviceCompletionHandler:^(NSString *deviceID, NSError *error) {
                expect(deviceID).to.beNil();
                expect(error).notTo.beNil();
                done();
            }];
        });
    });
});

SpecEnd
