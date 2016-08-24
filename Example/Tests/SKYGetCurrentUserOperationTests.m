//
//  SKYGetCurrentUserOperationTests.m
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

SpecBegin(SKYGetCurrentUserOperation)

    describe(@"get current user operation", ^{
        __block SKYContainer *container = nil;

        beforeEach(^{
            container = [[SKYContainer alloc] init];
            [container
                updateWithUserRecordID:@"user-1"
                           accessToken:[[SKYAccessToken alloc] initWithTokenString:@"token-1"]];
        });

        afterEach(^{
            [OHHTTPStubs removeAllStubs];
        });

        it(@"should prepare correct SKYRequest", ^{
            SKYGetCurrentUserOperation *operation = [[SKYGetCurrentUserOperation alloc] init];
            [operation setContainer:container];
            [operation prepareForRequest];

            SKYRequest *request = operation.request;
            expect([request class]).to.beSubclassOf([SKYRequest class]);
            expect(request.action).to.equal(@"me");
            expect(request.accessToken).to.equal(container.currentAccessToken);
        });

        it(@"should get correct user", ^{
            SKYGetCurrentUserOperation *operation = [[SKYGetCurrentUserOperation alloc] init];
            operation.container = container;

            [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *_Nonnull request) {
                return YES;
            }
                withStubResponse:^OHHTTPStubsResponse *_Nonnull(NSURLRequest *_Nonnull request) {
                    NSData *data = [NSJSONSerialization dataWithJSONObject:@{
                        @"result" : @{
                            @"user_id" : @"user-1",
                            @"username" : @"user1",
                            @"email" : @"user1@skygear.dev",
                            @"roles" : @[ @"Developer", @"Designer" ],
                            @"access_token" : @"token-1"
                        }
                    }
                                                                   options:0
                                                                     error:nil];
                    return [OHHTTPStubsResponse responseWithData:data statusCode:200 headers:@{}];
                }];

            waitUntil(^(DoneCallback done) {
                operation.getCurrentUserCompletionBlock =
                    ^(SKYUser *user, SKYAccessToken *accessToken, NSError *error) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            expect(error).to.beNil();

                            expect(accessToken).notTo.beNil();
                            expect(accessToken.tokenString).to.equal(@"token-1");

                            expect(user).notTo.beNil();
                            expect(user.userID).to.equal(@"user-1");
                            expect(user.username).to.equal(@"user1");
                            expect(user.email).to.equal(@"user1@skygear.dev");
                            expect(user.roles).to.haveLengthOf(2);
                            expect(user.roles).to.contain([SKYRole roleWithName:@"Developer"]);
                            expect(user.roles).to.contain([SKYRole roleWithName:@"Designer"]);

                            done();
                        });
                    };

                [container addOperation:operation];
            });

        });

        it(@"should handle error properly", ^{
            SKYGetCurrentUserOperation *operation = [[SKYGetCurrentUserOperation alloc] init];
            operation.container = container;

            [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *_Nonnull request) {
                return YES;
            }
                withStubResponse:^OHHTTPStubsResponse *_Nonnull(NSURLRequest *_Nonnull request) {
                    NSData *data = [NSJSONSerialization dataWithJSONObject:@{
                        @"error" : @{
                            @"name" : @"NotAuthenticated",
                            @"code" : @101,
                            @"message" : @"Authentication is needed to get current user"
                        }
                    }
                                                                   options:0
                                                                     error:nil];
                    return [OHHTTPStubsResponse responseWithData:data statusCode:401 headers:@{}];
                }];

            waitUntil(^(DoneCallback done) {
                operation.getCurrentUserCompletionBlock =
                    ^(SKYUser *user, SKYAccessToken *accessToken, NSError *error) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            expect(user).to.beNil();
                            expect(accessToken).to.beNil();
                            expect(error).notTo.beNil();

                            done();
                        });
                    };

                [container addOperation:operation];
            });
        });

    });

SpecEnd