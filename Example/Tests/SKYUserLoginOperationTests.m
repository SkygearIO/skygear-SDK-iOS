//
//  SKYUserLoginOperationTests.m
//  SkyKit
//
//  Created by Patrick Cheung on 25/2/15.
//  Copyright (c) 2015 Kwok-kuen Cheung. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SkyKit/SkyKit.h>
#import <OHHTTPStubs/OHHTTPStubs.h>

SpecBegin(SKYUserLoginOperation)

    describe(@"login", ^{
        __block SKYContainer *container = nil;

        beforeEach(^{
            container = [[SKYContainer alloc] init];
            [container configureWithAPIKey:@"API_KEY"];
            [container updateWithUserRecordID:[SKYUserRecordID recordIDWithUsername:@"USER_ID"]
                                  accessToken:[[SKYAccessToken alloc]
                                                  initWithTokenString:@"ACCESS_TOKEN"]];
        });

        it(@"make SKYRequest with username login", ^{
            SKYUserLoginOperation *operation =
                [SKYUserLoginOperation operationWithUsername:@"username" password:@"password"];
            operation.container = container;
            [operation prepareForRequest];
            SKYRequest *request = operation.request;
            expect([request class]).to.beSubclassOf([SKYRequest class]);
            expect(request.action).to.equal(@"auth:login");
            expect(request.accessToken).to.beNil();
            expect(request.APIKey).to.equal(@"API_KEY");
            expect(request.payload[@"username"]).to.equal(@"username");
            expect(request.payload[@"password"]).to.equal(@"password");
        });

        it(@"make SKYRequest with email login", ^{
            SKYUserLoginOperation *operation =
                [SKYUserLoginOperation operationWithEmail:@"user@example.com" password:@"password"];
            operation.container = container;
            [operation prepareForRequest];
            SKYRequest *request = operation.request;
            expect([request class]).to.beSubclassOf([SKYRequest class]);
            expect(request.action).to.equal(@"auth:login");
            expect(request.accessToken).to.beNil();
            expect(request.APIKey).to.equal(@"API_KEY");
            expect(request.payload[@"email"]).to.equal(@"user@example.com");
            expect(request.payload[@"password"]).to.equal(@"password");
        });

        it(@"make request", ^{
            SKYUserLoginOperation *operation =
                [SKYUserLoginOperation operationWithEmail:@"user@example.com" password:@"password"];

            [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
                return YES;
            }
                withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
                    NSDictionary *parameters = @{
                        @"user_id" : @"UUID",
                        @"access_token" : @"ACCESS_TOKEN",
                    };
                    NSData *payload = [NSJSONSerialization dataWithJSONObject:@{
                        @"result" : parameters
                    }
                                                                      options:0
                                                                        error:nil];

                    return
                        [OHHTTPStubsResponse responseWithData:payload statusCode:200 headers:@{}];
                }];

            waitUntil(^(DoneCallback done) {
                operation.loginCompletionBlock =
                    ^(SKYUserRecordID *recordID, SKYAccessToken *accessToken, NSError *error) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            expect(recordID.recordType).to.equal(@"_user");
                            expect(recordID.recordName).to.equal(@"UUID");
                            expect(accessToken.tokenString).to.equal(@"ACCESS_TOKEN");
                            expect(error).to.beNil();
                            done();
                        });
                    };

                [container addOperation:operation];
            });
        });

        it(@"pass error", ^{
            SKYUserLoginOperation *operation =
                [SKYUserLoginOperation operationWithEmail:@"user@example.com" password:@"password"];
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
