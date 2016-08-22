//
//  SKYDeleteSubscriptionsOperationTests.m
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

SpecBegin(SKYDeleteSubscriptionsOperation)

    describe(@"delete subscription", ^{
        __block SKYContainer *container = nil;
        __block SKYDatabase *database = nil;

        beforeEach(^{
            container = [[SKYContainer alloc] init];
            [container configureWithAPIKey:@"API_KEY"];
            [container updateWithUserRecordID:@"USER_ID"
                                  accessToken:[[SKYAccessToken alloc]
                                                  initWithTokenString:@"ACCESS_TOKEN"]];
            database = [container publicCloudDatabase];
        });

        it(@"multiple subscriptions", ^{
            SKYDeleteSubscriptionsOperation *operation = [SKYDeleteSubscriptionsOperation
                  operationWithDeviceID:@"DEVICE_ID"
                subscriptionIDsToDelete:@[ @"my notes", @"ben's notes" ]];
            operation.database = database;
            operation.container = container;
            [operation prepareForRequest];
            SKYRequest *request = operation.request;
            expect([request class]).to.beSubclassOf([SKYRequest class]);
            expect(request.action).to.equal(@"subscription:delete");
            expect(request.APIKey).to.equal(@"API_KEY");
            expect(request.accessToken).to.equal(container.currentAccessToken);
            expect(request.payload).to.equal(@{
                @"device_id" : @"DEVICE_ID",
                @"database_id" : database.databaseID,
                @"ids" : @[ @"my notes", @"ben's notes" ],
            });
        });

        it(@"make request", ^{
            SKYDeleteSubscriptionsOperation *operation = [SKYDeleteSubscriptionsOperation
                  operationWithDeviceID:@"DEVICE_ID"
                subscriptionIDsToDelete:@[ @"my notes", @"ben's notes" ]];

            [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
                return YES;
            }
                withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
                    NSDictionary *parameters = @{
                        @"request_id" : @"REQUEST_ID",
                        @"database_id" : database.databaseID,
                        @"result" : @[
                            @{@"id" : @"my notes"},
                            @{@"id" : @"ben's notes"},
                        ]
                    };
                    NSData *payload =
                        [NSJSONSerialization dataWithJSONObject:parameters options:0 error:nil];

                    return
                        [OHHTTPStubsResponse responseWithData:payload statusCode:200 headers:@{}];
                }];

            waitUntil(^(DoneCallback done) {
                operation.deleteSubscriptionsCompletionBlock =
                    ^(NSArray *subscriptionIDs, NSError *operationError) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            expect(subscriptionIDs).to.equal(@[ @"my notes", @"ben's notes" ]);
                            expect(operationError).to.beNil();
                            done();
                        });
                    };

                [database executeOperation:operation];
            });
        });

        it(@"pass error", ^{
            SKYDeleteSubscriptionsOperation *operation = [SKYDeleteSubscriptionsOperation
                  operationWithDeviceID:@"DEVICE_ID"
                subscriptionIDsToDelete:@[ @"my notes", @"ben's notes" ]];

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
                operation.deleteSubscriptionsCompletionBlock =
                    ^(NSArray *subscriptionIDs, NSError *operationError) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            expect(operationError).toNot.beNil();
                            done();
                        });
                    };

                [database executeOperation:operation];
            });
        });

        it(@"pass per item error", ^{
            SKYDeleteSubscriptionsOperation *operation = [SKYDeleteSubscriptionsOperation
                  operationWithDeviceID:@"DEVICE_ID"
                subscriptionIDsToDelete:@[ @"my notes", @"ben's notes" ]];

            [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
                return YES;
            }
                withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
                    NSDictionary *parameters = @{
                        @"request_id" : @"REQUEST_ID",
                        @"database_id" : database.databaseID,
                        @"result" : @[
                            @{@"id" : @"my notes"},
                            @{
                               @"_type" : @"error",
                               @"_id" : @"ben's notes",
                               @"message" : @"cannot find subscription \"ben's notes\"",
                               @"name" : @"ResourceNotFound",
                               @"code" : @(SKYErrorResourceNotFound),
                               @"info" : @{@"id" : @"ben's notes"},
                            },
                        ]
                    };
                    NSData *payload =
                        [NSJSONSerialization dataWithJSONObject:parameters options:0 error:nil];

                    return
                        [OHHTTPStubsResponse responseWithData:payload statusCode:200 headers:@{}];
                }];

            waitUntil(^(DoneCallback done) {
                operation.deleteSubscriptionsCompletionBlock = ^(NSArray *subscriptionIDs,
                                                                 NSError *operationError) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        expect(subscriptionIDs).to.equal(@[ @"my notes" ]);
                        expect(operationError).toNot.beNil();
                        expect(operationError.domain).to.equal(SKYOperationErrorDomain);
                        expect(operationError.code).to.equal(SKYErrorPartialFailure);

                        NSDictionary *errorBySubscriptionID =
                            operationError.userInfo[SKYPartialErrorsByItemIDKey];
                        expect(errorBySubscriptionID).toNot.beNil();
                        NSError *benError = errorBySubscriptionID[@"ben's notes"];
                        expect(benError).toNot.beNil();
                        expect(benError.code).to.equal(SKYErrorResourceNotFound);
                        expect(benError.userInfo[SKYErrorMessageKey])
                            .to.equal(@"cannot find subscription \"ben's notes\"");
                        expect(benError.userInfo[SKYErrorNameKey]).to.equal(@"ResourceNotFound");
                        expect(benError.userInfo[@"id"]).to.equal(@"ben's notes");
                        done();
                    });
                };

                [database executeOperation:operation];
            });
        });

        afterEach(^{
            [OHHTTPStubs removeAllStubs];
        });
    });

SpecEnd
