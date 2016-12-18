//
//  SKYUnregisterDeviceOperationTests.m
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
#import <OHHTTPStubs/OHHTTPStubs.h>
#import <SKYKit/SKYKit.h>

SpecBegin(SKYUnregisterDeviceOperation)

    describe(@"unregister", ^{
        __block SKYContainer *container = nil;

        beforeEach(^{
            container = [[SKYContainer alloc] init];
            [container updateWithUserRecordID:@"user_id"
                                  accessToken:[[SKYAccessToken alloc]
                                                  initWithTokenString:@"access_token"]];
        });

        afterEach(^{
            [OHHTTPStubs removeAllStubs];
        });

        it(@"creates correct request", ^{
            SKYUnregisterDeviceOperation *operation =
                [SKYUnregisterDeviceOperation operationWithDeviceID:@"device_id"];
            [operation setContainer:container];
            [operation prepareForRequest];

            SKYRequest *request = operation.request;
            expect([request class]).to.beSubclassOf([SKYRequest class]);
            expect(request.action).to.equal(@"device:unregister");
            expect(request.accessToken.tokenString).to.equal(@"access_token");
            expect(request.payload[@"id"]).to.equal(@"device_id");
        });

        it(@"handles response correctly", ^{
            SKYUnregisterDeviceOperation *operation =
                [SKYUnregisterDeviceOperation operationWithDeviceID:@"device_id"];

            [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
                return YES;
            }
                withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
                    NSDictionary *payloadDict = @{ @"result" : @{@"id" : @"device_id"} };
                    NSData *payloadData =
                        [NSJSONSerialization dataWithJSONObject:payloadDict options:0 error:nil];
                    return [OHHTTPStubsResponse responseWithData:payloadData
                                                      statusCode:200
                                                         headers:@{}];
                }];

            waitUntil(^(DoneCallback done) {
                operation.unregisterCompletionBlock = ^(NSString *deviceID, NSError *error) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        expect(deviceID).to.equal(@"device_id");
                        expect(error).to.beNil();

                        done();
                    });
                };

                [container addOperation:operation];
            });
        });

        it(@"handles error correctly", ^{
            SKYUnregisterDeviceOperation *operation =
                [SKYUnregisterDeviceOperation operationWithDeviceID:@"device_id"];

            [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
                return YES;
            }
                withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
                    NSDictionary *payloadDict = @{
                        @"error" : @{
                            @"name" : @"ResourceNotFound",
                            @"code" : @110,
                            @"message" : @"device not found"
                        }
                    };
                    NSData *payloadData =
                        [NSJSONSerialization dataWithJSONObject:payloadDict options:0 error:nil];
                    return [OHHTTPStubsResponse responseWithData:payloadData
                                                      statusCode:400
                                                         headers:@{}];
                }];

            waitUntil(^(DoneCallback done) {
                operation.unregisterCompletionBlock = ^(NSString *deviceID, NSError *error) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        expect(error).notTo.beNil();

                        done();
                    });
                };

                [container addOperation:operation];
            });
        });

    });

SpecEnd
