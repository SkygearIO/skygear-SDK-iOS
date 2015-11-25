//
//  SKYSignupUserOperationTests.m
//  SkyKit
//
//  Created by Patrick Cheung on 26/2/15.
//  Copyright (c) 2015 Kwok-kuen Cheung. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SkyKit/SkyKit.h>
#import <OHHTTPStubs/OHHTTPStubs.h>

SpecBegin(SKYSignupUserOperation)

    describe(@"create", ^{
        __block SKYContainer *container = nil;

        beforeEach(^{
            container = [[SKYContainer alloc] init];
            [container configureWithAPIKey:@"API_KEY"];
            [container updateWithUserRecordID:[SKYUserRecordID recordIDWithUsername:@"USER_ID"]
                                  accessToken:[[SKYAccessToken alloc]
                                                  initWithTokenString:@"ACCESS_TOKEN"]];
        });

        it(@"normal user request", ^{
            SKYSignupUserOperation *operation =
                [SKYSignupUserOperation operationWithEmail:@"user@example.com"
                                                  password:@"password"];
            operation.container = container;
            [operation prepareForRequest];
            SKYRequest *request = operation.request;
            expect([request class]).to.beSubclassOf([SKYRequest class]);
            expect(request.action).to.equal(@"auth:signup");
            expect(request.accessToken).to.beNil();
            expect(request.APIKey).to.equal(@"API_KEY");
            expect(request.payload[@"email"]).to.equal(@"user@example.com");
            expect(request.payload[@"password"]).to.equal(@"password");
        });

        it(@"anonymous user request", ^{
            SKYSignupUserOperation *operation =
                [SKYSignupUserOperation operationWithAnonymousUserAndPassword:@"password"];
            operation.container = container;
            [operation prepareForRequest];
            SKYRequest *request = operation.request;
            expect([request class]).to.beSubclassOf([SKYRequest class]);
            expect(request.action).to.equal(@"auth:signup");
            expect(request.accessToken).to.beNil();
            expect(request.APIKey).to.equal(@"API_KEY");
            expect(request.payload).notTo.contain(@"email");
        });

        it(@"make normal user request", ^{
            SKYSignupUserOperation *operation =
                [SKYSignupUserOperation operationWithEmail:@"user@example.com"
                                                  password:@"password"];

            [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
                return YES;
            }
                withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
                    NSDictionary *parameters = @{
                        @"result" : @{
                            @"user_id" : @"USER_ID",
                            @"access_token" : @"ACCESS_TOKEN",
                        },
                    };
                    NSData *payload =
                        [NSJSONSerialization dataWithJSONObject:parameters options:0 error:nil];

                    return
                        [OHHTTPStubsResponse responseWithData:payload statusCode:200 headers:@{}];
                }];

            waitUntil(^(DoneCallback done) {
                operation.signupCompletionBlock =
                    ^(SKYUserRecordID *recordID, SKYAccessToken *accessToken, NSError *error) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            expect(recordID.recordType).to.equal(@"_user");
                            expect(recordID.recordName).to.equal(@"USER_ID");
                            expect(accessToken.tokenString).to.equal(@"ACCESS_TOKEN");
                            expect(error).to.beNil();
                            done();
                        });
                    };

                [container addOperation:operation];
            });
        });

        it(@"make anonymous user request", ^{
            SKYSignupUserOperation *operation =
                [SKYSignupUserOperation operationWithAnonymousUserAndPassword:@"password"];

            [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
                return YES;
            }
                withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
                    NSDictionary *parameters = @{
                        @"result" : @{
                            @"user_id" : @"USER_ID",
                            @"access_token" : @"ACCESS_TOKEN",
                        },
                    };
                    NSData *payload =
                        [NSJSONSerialization dataWithJSONObject:parameters options:0 error:nil];

                    return
                        [OHHTTPStubsResponse responseWithData:payload statusCode:200 headers:@{}];
                }];

            waitUntil(^(DoneCallback done) {
                operation.signupCompletionBlock =
                    ^(SKYUserRecordID *recordID, SKYAccessToken *accessToken, NSError *error) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            expect(recordID.recordType).to.equal(@"_user");
                            expect(recordID.recordName).to.equal(@"USER_ID");
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
                [SKYSignupUserOperation operationWithEmail:@"user@example.com"
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
                operation.signupCompletionBlock =
                    ^(SKYUserRecordID *recordID, SKYAccessToken *accessToken, NSError *error) {
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
