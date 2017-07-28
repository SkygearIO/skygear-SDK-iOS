//
//  SKYLogoutUserOperationTests.m
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

SpecBegin(SKYLogoutUserOperation)

    describe(@"logout", ^{
        __block SKYContainer *container = nil;

        beforeEach(^{
            container = [[SKYContainer alloc] init];
            [container.auth updateWithUserRecordID:@"USER_ID"
                                       accessToken:[[SKYAccessToken alloc]
                                                       initWithTokenString:@"ACCESS_TOKEN"]];
        });

        it(@"make SKYRequest", ^{
            SKYLogoutUserOperation *operation = [[SKYLogoutUserOperation alloc] init];
            operation.container = container;
            [operation prepareForRequest];
            SKYRequest *request = operation.request;
            expect([request class]).to.beSubclassOf([SKYRequest class]);
            expect(request.action).to.equal(@"auth:logout");
            expect(request.accessToken).to.equal(container.auth.currentAccessToken);
        });

        it(@"make request", ^{
            SKYLogoutUserOperation *operation = [[SKYLogoutUserOperation alloc] init];

            [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
                return YES;
            }
                withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
                    NSDictionary *parameters = @{};
                    NSData *payload =
                        [NSJSONSerialization dataWithJSONObject:@{@"result" : parameters}
                                                        options:0
                                                          error:nil];

                    return
                        [OHHTTPStubsResponse responseWithData:payload statusCode:200 headers:@{}];
                }];

            waitUntil(^(DoneCallback done) {
                operation.logoutCompletionBlock = ^(NSError *error) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        done();
                    });
                };

                [container addOperation:operation];
            });
        });

        it(@"pass error", ^{
            SKYLogoutUserOperation *operation = [[SKYLogoutUserOperation alloc] init];
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
                operation.logoutCompletionBlock = ^(NSError *error) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        expect(error).toNot.beNil();
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
