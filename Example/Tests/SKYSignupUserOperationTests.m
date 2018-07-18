//
//  SKYSignupUserOperationTests.m
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

SpecBegin(SKYSignupUserOperation)

    describe(@"create", ^{
        __block SKYContainer *container = nil;

        beforeEach(^{
            container = [SKYContainer testContainer];
            [container.auth updateWithUserRecordID:@"USER_ID"
                                       accessToken:[[SKYAccessToken alloc] initWithTokenString:@"ACCESS_TOKEN"]];
        });

        it(@"normal user request", ^{
            SKYSignupUserOperation *operation =
                [SKYSignupUserOperation operationWithAuthData:@{@"email" : @"user@example.com"} password:@"password"];

            operation.container = container;
            [operation makeURLRequestWithError:nil];
            SKYRequest *request = operation.request;
            expect([request class]).to.beSubclassOf([SKYRequest class]);
            expect(request.action).to.equal(@"auth:signup");
            expect(request.accessToken).to.beNil();
            expect(request.APIKey).to.equal(@"API_KEY");
            expect(request.payload[@"auth_data"][@"email"]).to.equal(@"user@example.com");
            expect(request.payload[@"password"]).to.equal(@"password");
        });

        it(@"anonymous user request", ^{
            SKYSignupUserOperation *operation = [SKYSignupUserOperation operationWithAnonymousUser];
            operation.container = container;
            [operation makeURLRequestWithError:nil];
            SKYRequest *request = operation.request;
            expect([request class]).to.beSubclassOf([SKYRequest class]);
            expect(request.action).to.equal(@"auth:signup");
            expect(request.accessToken).to.beNil();
            expect(request.APIKey).to.equal(@"API_KEY");
            expect(request.payload).notTo.contain(@"email");
        });

        it(@"make normal user request", ^{
            SKYSignupUserOperation *operation =
                [SKYSignupUserOperation operationWithAuthData:@{@"email" : @"user@example.com"} password:@"password"];

            [OHHTTPStubs
                stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
                    return YES;
                }
                withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
                    NSDictionary *parameters = @{
                        @"result" : @{
                            @"user_id" : @"USER_ID",
                            @"access_token" : @"ACCESS_TOKEN",
                            @"profile" : @{
                                @"_id" : @"user/USER_ID",
                                @"_access" : [NSNull null],
                                @"email" : @"user@example.com",
                            },
                        },
                    };
                    NSData *payload = [NSJSONSerialization dataWithJSONObject:parameters options:0 error:nil];

                    return [OHHTTPStubsResponse responseWithData:payload statusCode:200 headers:@{}];
                }];

            waitUntil(^(DoneCallback done) {
                operation.signupCompletionBlock = ^(SKYRecord *user, SKYAccessToken *accessToken, NSError *error) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        expect(user.recordID.recordType).to.equal(@"user");
                        expect(user.recordID.recordName).to.equal(@"USER_ID");
                        expect(user[@"email"]).to.equal(@"user@example.com");
                        expect(accessToken.tokenString).to.equal(@"ACCESS_TOKEN");
                        expect(error).to.beNil();
                        done();
                    });
                };

                [container addOperation:operation];
            });
        });

        it(@"make anonymous user request", ^{
            SKYSignupUserOperation *operation = [SKYSignupUserOperation operationWithAnonymousUser];

            [OHHTTPStubs
                stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
                    return YES;
                }
                withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
                    NSDictionary *parameters = @{
                        @"result" : @{
                            @"user_id" : @"USER_ID",
                            @"access_token" : @"ACCESS_TOKEN",
                            @"profile" : @{
                                @"_id" : @"user/USER_ID",
                                @"_access" : [NSNull null],
                            },
                        },
                    };
                    NSData *payload = [NSJSONSerialization dataWithJSONObject:parameters options:0 error:nil];

                    return [OHHTTPStubsResponse responseWithData:payload statusCode:200 headers:@{}];
                }];

            waitUntil(^(DoneCallback done) {
                operation.signupCompletionBlock = ^(SKYRecord *user, SKYAccessToken *accessToken, NSError *error) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        expect(user.recordID.recordType).to.equal(@"user");
                        expect(user.recordID.recordName).to.equal(@"USER_ID");
                        expect(accessToken.tokenString).to.equal(@"ACCESS_TOKEN");
                        expect(error).to.beNil();
                        done();
                    });
                };

                [container addOperation:operation];
            });
        });

        it(@"pass error", ^{
            SKYSignupUserOperation *operation =
                [SKYSignupUserOperation operationWithAuthData:@{@"email" : @"user@example.com"} password:@"password"];
            [OHHTTPStubs
                stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
                    return YES;
                }
                withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
                    return [OHHTTPStubsResponse
                        responseWithError:[NSError errorWithDomain:NSURLErrorDomain code:0 userInfo:nil]];
                }];

            waitUntil(^(DoneCallback done) {
                operation.signupCompletionBlock = ^(SKYRecord *user, SKYAccessToken *accessToken, NSError *error) {
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
