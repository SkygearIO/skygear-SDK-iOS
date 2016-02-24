//
//  SKYChangePasswordOperationTests.m
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

#import <OHHTTPStubs/OHHTTPStubs.h>
#import <SKYKit/SKYKit.h>

SpecBegin(SKYChangePasswordOperation)

    describe(@"login", ^{
        __block SKYContainer *container = nil;

        beforeEach(^{
            container = [[SKYContainer alloc] init];
            [container configureWithAPIKey:@"API_KEY"];
            [container updateWithUserRecordID:@"USER_ID"
                                  accessToken:[[SKYAccessToken alloc]
                                                  initWithTokenString:@"ACCESS_TOKEN"]];
        });

        it(@"make SKYRequest with old password and new password", ^{
            SKYChangePasswordOperation *operation =
                [SKYChangePasswordOperation operationWithOldPassword:@"old_password"
                                                       passwordToSet:@"new_password"];

            operation.container = container;
            [operation prepareForRequest];

            SKYRequest *request = operation.request;
            expect(request.action).to.equal(@"auth:password");
            expect(request.accessToken.tokenString).to.equal(@"ACCESS_TOKEN");
            expect(request.payload)
                .to.equal(@{
                    @"old_password" : @"old_password",
                    @"password" : @"new_password",
                });
        });

        it(@"make request", ^{
            SKYChangePasswordOperation *operation =
                [SKYChangePasswordOperation operationWithOldPassword:@"old_password"
                                                       passwordToSet:@"new_password"];

            [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
                return YES;
            }
                withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
                    NSDictionary *resp = @{
                        @"result" : @{
                            @"user_id" : @"UUID",
                            @"access_token" : @"ACCESS_TOKEN",
                        },
                    };
                    return [OHHTTPStubsResponse responseWithJSONObject:resp
                                                            statusCode:200
                                                               headers:nil];
                }];

            waitUntil(^(DoneCallback done) {
                operation.changePasswordCompletionBlock =
                    ^(SKYUser *user, SKYAccessToken *accessToken, NSError *error) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            expect(user.recordID).to.equal(@"UUID");
                            expect(accessToken.tokenString).to.equal(@"ACCESS_TOKEN");
                            expect(error).to.beNil();
                            done();
                        });
                    };

                [container addOperation:operation];
            });
        });

        it(@"pass error", ^{
            SKYChangePasswordOperation *operation =
                [SKYChangePasswordOperation operationWithOldPassword:@"old_password"
                                                       passwordToSet:@"new_password"];

            [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
                return YES;
            }
                withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
                    NSDictionary *resp = @{
                        @"error" : @{
                            @"type" : @"InvalidCredentials",
                            @"code" : @(SKYErrorInvalidCredentials),
                            @"message" : @"Incorrect Old Password",
                        },
                    };
                    return [OHHTTPStubsResponse responseWithJSONObject:resp
                                                            statusCode:400
                                                               headers:nil];
                }];

            waitUntil(^(DoneCallback done) {
                operation.changePasswordCompletionBlock =
                    ^(SKYUser *user, SKYAccessToken *accessToken, NSError *error) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            expect(error).toNot.beNil();
                            expect(error.code).to.equal(SKYErrorInvalidCredentials);
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
