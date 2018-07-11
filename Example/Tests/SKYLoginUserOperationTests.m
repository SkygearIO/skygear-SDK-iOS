//
//  SKYLoginUserOperationTests.m
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

SpecBegin(SKYLoginUserOperation)

    describe(@"login", ^{
        __block SKYContainer *container = nil;

        beforeEach(^{
            container = [SKYContainer testContainer];
            [container.auth updateWithUserRecordID:@"USER_ID"
                                       accessToken:[[SKYAccessToken alloc]
                                                       initWithTokenString:@"ACCESS_TOKEN"]];
        });

        it(@"make SKYRequest with username login", ^{
            SKYLoginUserOperation *operation =
                [SKYLoginUserOperation operationWithAuthData:@{@"username" : @"username"}
                                                    password:@"password"];
            operation.container = container;
            [operation makeURLRequestWithError:nil];
            SKYRequest *request = operation.request;
            expect([request class]).to.beSubclassOf([SKYRequest class]);
            expect(request.action).to.equal(@"auth:login");
            expect(request.accessToken).to.beNil();
            expect(request.APIKey).to.equal(@"API_KEY");
            expect(request.payload[@"auth_data"][@"username"]).to.equal(@"username");
            expect(request.payload[@"password"]).to.equal(@"password");
        });

        it(@"make SKYRequest with email login", ^{
            SKYLoginUserOperation *operation =
                [SKYLoginUserOperation operationWithAuthData:@{@"email" : @"user@example.com"}
                                                    password:@"password"];
            operation.container = container;
            [operation makeURLRequestWithError:nil];
            SKYRequest *request = operation.request;
            expect([request class]).to.beSubclassOf([SKYRequest class]);
            expect(request.action).to.equal(@"auth:login");
            expect(request.accessToken).to.beNil();
            expect(request.APIKey).to.equal(@"API_KEY");
            expect(request.payload[@"auth_data"][@"email"]).to.equal(@"user@example.com");
            expect(request.payload[@"password"]).to.equal(@"password");
        });

        it(@"make SKYRequest with provider", ^{
            SKYLoginUserOperation *operation =
                [SKYLoginUserOperation operationWithProvider:@"com.example"
                                            providerAuthData:@{
                                                @"access_token" : @"hello_world",
                                            }];
            operation.container = container;
            [operation makeURLRequestWithError:nil];
            SKYRequest *request = operation.request;
            expect([request class]).to.beSubclassOf([SKYRequest class]);
            expect(request.action).to.equal(@"auth:login");
            expect(request.accessToken).to.beNil();
            expect(request.APIKey).to.equal(@"API_KEY");
            expect(request.payload[@"provider"]).to.equal(@"com.example");
            expect(request.payload[@"provider_auth_data"]).to.equal(@{
                @"access_token" : @"hello_world"
            });
        });

        it(@"make request", ^{
            SKYLoginUserOperation *operation =
                [SKYLoginUserOperation operationWithAuthData:@{@"email" : @"user@example.com"}
                                                    password:@"password"];

            [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
                return YES;
            }
                withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
                    NSDictionary *parameters = @{
                        @"user_id" : @"UUID",
                        @"access_token" : @"ACCESS_TOKEN",
                        @"profile" : @{
                            @"_recordType" : @"user",
                            @"_recordID" : @"UUID",
                            @"_access" : [NSNull null],
                        },
                    };
                    NSData *payload =
                        [NSJSONSerialization dataWithJSONObject:@{@"result" : parameters}
                                                        options:0
                                                          error:nil];

                    return
                        [OHHTTPStubsResponse responseWithData:payload statusCode:200 headers:@{}];
                }];

            waitUntil(^(DoneCallback done) {
                operation.loginCompletionBlock =
                    ^(SKYRecord *user, SKYAccessToken *accessToken, NSError *error) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            expect(user.recordID.recordType).to.equal(@"user");
                            expect(user.recordID.recordName).to.equal(@"UUID");
                            expect(accessToken.tokenString).to.equal(@"ACCESS_TOKEN");
                            expect(error).to.beNil();
                            done();
                        });
                    };

                [container addOperation:operation];
            });
        });

        it(@"pass error", ^{
            SKYLoginUserOperation *operation =
                [SKYLoginUserOperation operationWithAuthData:@{@"email" : @"user@example.com"}
                                                    password:@"password"];
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
                operation.loginCompletionBlock =
                    ^(SKYRecord *user, SKYAccessToken *accessToken, NSError *error) {
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
