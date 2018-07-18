//
//  SKYOperationTests.m
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

#import "SKYOperation_Private.h"
#import <Foundation/Foundation.h>
#import <OHHTTPStubs/OHHTTPStubs.h>
#import <SKYKit/SKYKit.h>

SpecBegin(SKYOperation)

    describe(@"request", ^{
        __block SKYContainer *container = nil;

        beforeEach(^{
            container = [SKYContainer testContainer];
            [container.auth updateWithUserRecordID:@"USER_ID"
                                       accessToken:[[SKYAccessToken alloc] initWithTokenString:@"ACCESS_TOKEN"]];
        });

        it(@"make http request", ^{
            NSString *action = @"auth:login";
            NSDictionary *payload = @{};

            SKYRequest *request = [[SKYRequest alloc] initWithAction:action payload:payload];
            SKYOperation *operation = [[SKYOperation alloc] initWithRequest:request];

            [OHHTTPStubs
                stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
                    return YES;
                }
                withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
                    expect(operation.executing).to.equal(YES);

                    NSData *data = [NSJSONSerialization dataWithJSONObject:@{} options:0 error:nil];

                    return [[OHHTTPStubsResponse alloc] initWithData:data statusCode:200 headers:@{}];
                }];

            waitUntil(^(DoneCallback done) {
                __block typeof(operation) blockOp = operation;
                operation.completionBlock = ^{
                    dispatch_async(dispatch_get_main_queue(), ^{
                        expect(blockOp.finished).to.equal(YES);
                        expect(blockOp.lastError).to.beNil();
                        done();
                    });
                };
                [container addOperation:operation];
            });
        });

        it(@"handle NSError", ^{
            NSString *action = @"auth:login";
            NSDictionary *payload = @{};

            SKYRequest *request = [[SKYRequest alloc] initWithAction:action payload:payload];
            SKYOperation *operation = [[SKYOperation alloc] initWithRequest:request];

            [OHHTTPStubs
                stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
                    return YES;
                }
                withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
                    expect(operation.executing).to.equal(YES);

                    NSError *networkError =
                        [NSError errorWithDomain:NSURLErrorDomain
                                            code:-1001
                                        userInfo:@{
                                            NSLocalizedDescriptionKey :
                                                NSLocalizedString(@"The operation couldn’t be completed.", nil),
                                            NSURLErrorFailingURLStringErrorKey : request.URL
                                        }];
                    return [[OHHTTPStubsResponse alloc] initWithError:networkError];
                }];

            waitUntil(^(DoneCallback done) {
                __block typeof(operation) blockOp = operation;
                operation.completionBlock = ^{
                    dispatch_async(dispatch_get_main_queue(), ^{
                        expect(blockOp.finished).to.equal(YES);

                        NSError *error = blockOp.lastError;
                        expect([error class]).to.beSubclassOf([NSError class]);
                        expect(error.domain).to.equal(SKYOperationErrorDomain);
                        expect(error.code).to.equal(SKYErrorNetworkFailure);
                        expect([error.userInfo[NSUnderlyingErrorKey] code]).to.equal(-1001);
                        done();
                    });
                };
                [container addOperation:operation];
            });
        });

        it(@"handle non json response", ^{
            NSString *action = @"auth:login";
            NSDictionary *payload = @{};

            SKYRequest *request = [[SKYRequest alloc] initWithAction:action payload:payload];
            SKYOperation *operation = [[SKYOperation alloc] initWithRequest:request];

            [OHHTTPStubs
                stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
                    return YES;
                }
                withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
                    expect(operation.executing).to.equal(YES);

                    return [[OHHTTPStubsResponse alloc]
                        initWithData:[@"INVALID DATA" dataUsingEncoding:NSUTF8StringEncoding]
                          statusCode:200
                             headers:@{}];
                }];

            waitUntil(^(DoneCallback done) {
                __block typeof(operation) blockOp = operation;
                operation.completionBlock = ^{
                    dispatch_async(dispatch_get_main_queue(), ^{
                        expect(blockOp.finished).to.equal(YES);
                        expect([blockOp.lastError class]).to.beSubclassOf([NSError class]);
                        expect([(NSError *)[blockOp.lastError userInfo][NSUnderlyingErrorKey] code]).to.equal(3840);
                        done();
                    });
                };
                [container addOperation:operation];
            });
        });

        it(@"handle array JSON response", ^{
            NSString *action = @"auth:login";
            NSDictionary *payload = @{};

            SKYRequest *request = [[SKYRequest alloc] initWithAction:action payload:payload];
            SKYOperation *operation = [[SKYOperation alloc] initWithRequest:request];

            [OHHTTPStubs
                stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
                    return YES;
                }
                withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
                    expect(operation.executing).to.equal(YES);

                    NSData *data = [NSJSONSerialization dataWithJSONObject:@[] options:0 error:nil];

                    return [[OHHTTPStubsResponse alloc] initWithData:data statusCode:200 headers:@{}];
                }];

            waitUntil(^(DoneCallback done) {
                __block typeof(operation) blockOp = operation;
                operation.completionBlock = ^{
                    dispatch_async(dispatch_get_main_queue(), ^{
                        expect(blockOp.finished).to.equal(YES);
                        expect([blockOp.lastError class]).to.beSubclassOf([NSError class]);
                        // FIXME: More concrete checks of the error?
                        done();
                    });
                };
                [container addOperation:operation];
            });
        });

        it(@"handle 400", ^{
            NSString *action = @"auth:login";
            NSDictionary *payload = @{};

            SKYRequest *request = [[SKYRequest alloc] initWithAction:action payload:payload];
            SKYOperation *operation = [[SKYOperation alloc] initWithRequest:request];

            [OHHTTPStubs
                stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
                    return YES;
                }
                withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
                    expect(operation.executing).to.equal(YES);

                    NSData *data = [NSJSONSerialization dataWithJSONObject:@{
                        @"error" : @{
                            @"message" : @"Unable to login.",
                            @"code" : @(SKYErrorInvalidCredentials),
                            @"name" : @"InvalidCredentials",
                            @"info" : @{
                                @"username" : @"user@example.com",
                            },
                        }
                    }
                                                                   options:0
                                                                     error:nil];

                    return [[OHHTTPStubsResponse alloc] initWithData:data statusCode:401 headers:@{}];
                }];

            waitUntil(^(DoneCallback done) {
                __block typeof(operation) blockOp = operation;
                operation.completionBlock = ^{
                    dispatch_async(dispatch_get_main_queue(), ^{
                        expect(blockOp.finished).to.equal(YES);
                        NSError *error = blockOp.lastError;
                        expect([error class]).to.beSubclassOf([NSError class]);
                        expect(error.code).to.equal(SKYErrorInvalidCredentials);
                        expect(error.userInfo[SKYErrorNameKey]).to.equal(@"InvalidCredentials");
                        expect(error.userInfo[SKYErrorMessageKey]).to.equal(@"Unable to login.");
                        expect(error.userInfo[SKYOperationErrorHTTPStatusCodeKey]).to.equal(@(401));
                        expect(error.userInfo[@"username"]).to.equal(@"user@example.com");
                        done();
                    });
                };
                [container addOperation:operation];
            });
        });

        it(@"handle 500", ^{
            NSString *action = @"auth:login";
            NSDictionary *payload = @{};

            SKYRequest *request = [[SKYRequest alloc] initWithAction:action payload:payload];
            SKYOperation *operation = [[SKYOperation alloc] initWithRequest:request];

            [OHHTTPStubs
                stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
                    return YES;
                }
                withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
                    expect(operation.executing).to.equal(YES);

                    NSData *data = [NSJSONSerialization dataWithJSONObject:@{
                        @"error" : @{
                            @"message" : @"Unable to login.",
                            @"code" : @(SKYErrorUnexpectedError),
                            @"name" : @"UnexpectedError",
                            @"info" : @{
                                @"username" : @"user@example.com",
                            },
                        }
                    }
                                                                   options:0
                                                                     error:nil];

                    return [[OHHTTPStubsResponse alloc] initWithData:data statusCode:500 headers:@{}];
                }];

            waitUntil(^(DoneCallback done) {
                __block typeof(operation) blockOp = operation;
                operation.completionBlock = ^{
                    dispatch_async(dispatch_get_main_queue(), ^{
                        expect(blockOp.finished).to.equal(YES);
                        NSError *error = blockOp.lastError;
                        expect([error class]).to.beSubclassOf([NSError class]);
                        expect(error.code).to.equal(SKYErrorUnexpectedError);
                        expect(error.userInfo[SKYErrorNameKey]).to.equal(@"UnexpectedError");
                        expect(error.userInfo[SKYErrorMessageKey]).to.equal(@"Unable to login.");
                        expect(error.userInfo[SKYOperationErrorHTTPStatusCodeKey]).to.equal(@(500));
                        expect(error.userInfo[@"username"]).to.equal(@"user@example.com");
                        done();
                    });
                };
                [container addOperation:operation];
            });
        });

        it(@"error when container is not configured", ^{
            SKYContainer *container = [[SKYContainer alloc] init];
            container.pubsub.autoInternalPubsub = NO;

            SKYLogoutUserOperation *operation = [[SKYLogoutUserOperation alloc] init];

            waitUntil(^(DoneCallback done) {
                __block typeof(operation) blockOp = operation;
                operation.logoutCompletionBlock = ^(NSError *error) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        expect(blockOp.finished).to.equal(YES);
                        expect(blockOp.lastError).toNot.beNil();
                        expect(blockOp.lastError.code).to.equal(SKYErrorContainerNotConfigured);
                        expect(error).toNot.beNil();
                        expect(error.code).to.equal(SKYErrorContainerNotConfigured);
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
