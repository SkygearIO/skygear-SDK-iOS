//
//  SKYRegisterDeviceOperationTests.m
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

#import "SKYHexer.h"
#import <Foundation/Foundation.h>
#import <OHHTTPStubs/OHHTTPStubs.h>
#import <SKYKit/SKYKit.h>

SpecBegin(SKYRegisterDeviceOperation)

    describe(@"register", ^{
        __block SKYContainer *container = nil;

        beforeEach(^{
            container = [SKYContainer testContainer];
            [container.auth updateWithUserRecordID:@"USER_ID"
                                       accessToken:[[SKYAccessToken alloc]
                                                       initWithTokenString:@"ACCESS_TOKEN"]];
        });

        it(@"new device request", ^{
            SKYRegisterDeviceOperation *operation = [SKYRegisterDeviceOperation
                operationWithDeviceToken:[SKYHexer dataWithHexString:@"abcdef1234567890"]
                                   topic:@"com.example.app"];
            operation.container = container;
            [operation makeURLRequestWithError:nil];

            SKYRequest *request = operation.request;
            expect([request class]).to.beSubclassOf([SKYRequest class]);
            expect(request.action).to.equal(@"device:register");
            expect(request.accessToken).to.equal(container.auth.currentAccessToken);
            expect(request.payload[@"type"]).to.equal(@"ios");
            expect(request.payload[@"device_token"]).to.equal(@"abcdef1234567890");
            expect(request.payload[@"id"]).to.beNil();
            expect(request.payload[@"topic"]).to.equal(@"com.example.app");
        });

        it(@"new device request without device token", ^{
            SKYRegisterDeviceOperation *operation =
                [SKYRegisterDeviceOperation operationWithDeviceToken:nil topic:@"com.example.app"];
            operation.container = container;
            [operation makeURLRequestWithError:nil];

            SKYRequest *request = operation.request;
            expect([request class]).to.beSubclassOf([SKYRequest class]);
            expect(request.action).to.equal(@"device:register");
            expect(request.accessToken).to.equal(container.auth.currentAccessToken);
            expect(request.payload[@"type"]).to.equal(@"ios");
            expect(request.payload[@"device_token"]).to.beNil();
            expect(request.payload[@"id"]).to.beNil();
            expect(request.payload[@"topic"]).to.equal(@"com.example.app");
        });

        it(@"update device request", ^{
            SKYRegisterDeviceOperation *operation = [SKYRegisterDeviceOperation
                operationWithDeviceToken:[SKYHexer dataWithHexString:@"abcdef1234567890"]
                                   topic:@"com.example.app"];
            operation.deviceID = @"DEVICE_ID";
            operation.container = container;
            [operation makeURLRequestWithError:nil];

            SKYRequest *request = operation.request;
            expect([request class]).to.beSubclassOf([SKYRequest class]);
            expect(request.action).to.equal(@"device:register");
            expect(request.accessToken).to.equal(container.auth.currentAccessToken);
            expect(request.payload[@"type"]).to.equal(@"ios");
            expect(request.payload[@"device_token"]).to.equal(@"abcdef1234567890");
            expect(request.payload[@"id"]).to.equal(@"DEVICE_ID");
            expect(request.payload[@"topic"]).to.equal(@"com.example.app");
        });

        it(@"new device response", ^{
            SKYRegisterDeviceOperation *operation = [SKYRegisterDeviceOperation
                operationWithDeviceToken:[SKYHexer dataWithHexString:@"abcdef1234567890"]
                                   topic:@"com.example.app"];

            [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
                return YES;
            }
                withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
                    NSDictionary *parameters = @{
                        @"result" : @{
                            @"id" : @"DEVICE_ID",
                        },
                    };
                    NSData *payload =
                        [NSJSONSerialization dataWithJSONObject:parameters options:0 error:nil];

                    return
                        [OHHTTPStubsResponse responseWithData:payload statusCode:200 headers:@{}];
                }];

            waitUntil(^(DoneCallback done) {
                operation.registerCompletionBlock = ^(NSString *deviceID, NSError *operationError) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        expect(deviceID).to.equal(@"DEVICE_ID");
                        done();
                    });
                };
                [container addOperation:operation];
            });
        });

        it(@"error with response without id", ^{
            SKYRegisterDeviceOperation *operation = [SKYRegisterDeviceOperation
                operationWithDeviceToken:[SKYHexer dataWithHexString:@"abcdef1234567890"]
                                   topic:@"com.example.app"];

            [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
                return YES;
            }
                withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
                    NSDictionary *parameters = @{
                        @"result" : @{},
                    };
                    NSData *payload =
                        [NSJSONSerialization dataWithJSONObject:parameters options:0 error:nil];

                    return
                        [OHHTTPStubsResponse responseWithData:payload statusCode:200 headers:@{}];
                }];

            waitUntil(^(DoneCallback done) {
                operation.registerCompletionBlock = ^(NSString *deviceID, NSError *operationError) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        expect(operationError).toNot.beNil();
                        done();
                    });
                };
                [container addOperation:operation];
            });
        });

        it(@"pass error", ^{
            SKYRegisterDeviceOperation *operation = [SKYRegisterDeviceOperation
                operationWithDeviceToken:[SKYHexer dataWithHexString:@"abcdef1234567890"]
                                   topic:@"com.example.app"];
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
                operation.registerCompletionBlock = ^(NSString *deviceID, NSError *operationError) {
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
