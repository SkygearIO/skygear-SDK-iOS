//
//  SKYDisableUserOperation.m
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
#import <SKYKit/SKYKit.h>

SpecBegin(SKYSetDisableUserOperation)

    describe(@"Set Disable User Operation", ^{
        NSString *apiKey = @"CORRECT_KEY";
        NSString *currentUserID = @"CORRECT_USER_ID";
        NSString *token = @"CORRECT_TOKEN";

        NSString *disableMessage = @"some reason";
        NSDate *disableExpiry = [[NSDate date] dateByAddingTimeInterval:60 * 60];

        __block SKYContainer *container;

        beforeEach(^{
            container = [[SKYContainer alloc] init];
            [container configureWithAPIKey:apiKey];
            [container.auth
                updateWithUserRecordID:currentUserID
                           accessToken:[[SKYAccessToken alloc] initWithTokenString:token]];
        });

        it(@"should create SKYRequest correctly for enable user", ^{
            SKYSetDisableUserOperation *operation =
                [SKYSetDisableUserOperation enableOperationWithUserID:currentUserID];

            [operation setContainer:container];
            [operation prepareForRequest];

            SKYRequest *request = operation.request;
            expect(request.action).to.equal(@"auth:disable:set");
            expect(request.accessToken.tokenString).to.equal(token);

            expect(request.payload[@"auth_id"]).to.equal(currentUserID);
            expect(request.payload[@"disabled"]).to.beFalsy();
            expect(request.payload).notTo.contain(@"message");
            expect(request.payload).notTo.contain(@"expiry");
        });

        it(@"should create SKYRequest correctly for disable user", ^{
            SKYSetDisableUserOperation *operation =
                [SKYSetDisableUserOperation disableOperationWithUserID:currentUserID
                                                               message:disableMessage
                                                                expiry:disableExpiry];

            [operation setContainer:container];
            [operation prepareForRequest];

            SKYRequest *request = operation.request;
            expect(request.action).to.equal(@"auth:disable:set");
            expect(request.accessToken.tokenString).to.equal(token);

            expect(request.payload[@"auth_id"]).to.equal(currentUserID);
            expect(request.payload[@"disabled"]).to.beTruthy();
            expect(request.payload[@"message"]).to.equal(disableMessage);
            expect(request.payload[@"expiry"])
                .to.equal([SKYDataSerialization stringFromDate:disableExpiry]);
        });

        it(@"should create SKYRequest correctly for disable user without optional fields", ^{
            SKYSetDisableUserOperation *operation =
                [SKYSetDisableUserOperation disableOperationWithUserID:currentUserID
                                                               message:nil
                                                                expiry:nil];

            [operation setContainer:container];
            [operation prepareForRequest];

            SKYRequest *request = operation.request;
            expect(request.action).to.equal(@"auth:disable:set");
            expect(request.accessToken.tokenString).to.equal(token);

            expect(request.payload[@"auth_id"]).to.equal(currentUserID);
            expect(request.payload[@"disabled"]).to.beTruthy();
            expect(request.payload).notTo.contain(@"message");
            expect(request.payload).notTo.contain(@"expiry");
        });

        it(@"should handle success response correctly", ^{
            [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
                return YES;
            }
                withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
                    NSDictionary *response = @{@"result" : @"OK"};
                    return [OHHTTPStubsResponse responseWithJSONObject:response
                                                            statusCode:200
                                                               headers:nil];
                }];

            SKYSetDisableUserOperation *operation =
                [SKYSetDisableUserOperation disableOperationWithUserID:currentUserID
                                                               message:disableMessage
                                                                expiry:disableExpiry];
            [operation setContainer:container];

            waitUntil(^(DoneCallback done) {
                operation.setCompletionBlock = ^(NSString *userID, NSError *error) {
                    expect(userID).to.equal(currentUserID);
                    expect(error).to.beNil();

                    done();
                };

                [container addOperation:operation];
            });
        });

        it(@"should handle error response correctly", ^{
            [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
                return YES;
            }
                withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
                    return [OHHTTPStubsResponse
                        responseWithError:[NSError errorWithDomain:NSURLErrorDomain
                                                              code:0
                                                          userInfo:nil]];
                }];

            SKYSetDisableUserOperation *operation =
                [SKYSetDisableUserOperation disableOperationWithUserID:currentUserID
                                                               message:disableMessage
                                                                expiry:disableExpiry];
            [operation setContainer:container];

            waitUntil(^(DoneCallback done) {
                operation.setCompletionBlock = ^(NSString *userID, NSError *error) {
                    expect(userID).to.equal(currentUserID);
                    expect(error).toNot.beNil();

                    done();
                };

                [container addOperation:operation];
            });
        });

        afterEach(^{
            [OHHTTPStubs removeAllStubs];
        });
    });

SpecEnd
