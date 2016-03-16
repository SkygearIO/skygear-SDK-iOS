//
//  SKYDiscoverUsersOperationTests.m
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

SpecBegin(SKYDiscoverUsersOperation)

    describe(@"discover", ^{
        __block SKYContainer *container = nil;

        beforeEach(^{
            container = [[SKYContainer alloc] init];
            [container updateWithUserRecordID:@"USER_ID"
                                  accessToken:[[SKYAccessToken alloc]
                                                  initWithTokenString:@"ACCESS_TOKEN"]];
        });

        it(@"multiple emails", ^{
            SKYQueryUsersOperation *operation =
                [SKYQueryUsersOperation discoverUsersOperationByEmails:@[
                    @"john.doe@example.com", @"jane.doe@example.com"
                ]];
            operation.container = container;
            [operation prepareForRequest];
            SKYRequest *request = operation.request;
            expect([request class]).to.beSubclassOf([SKYRequest class]);
            expect(request.action).to.equal(@"user:query");
            expect(request.accessToken.tokenString).to.equal(@"ACCESS_TOKEN");
            expect(request.payload).to.equal(@{
                @"emails" : @[ @"john.doe@example.com", @"jane.doe@example.com" ],
            });
        });

        it(@"query relation", ^{
            SKYQueryUsersOperation *operation =
                [SKYQueryUsersOperation queryUsersOperationByRelation:[SKYRelation followedRelation]
                                                            direction:SKYRelationDirectionMutual];
            operation.container = container;
            [operation prepareForRequest];

            SKYRequest *request = operation.request;
            expect([request class]).to.beSubclassOf([SKYRequest class]);
            expect(request.accessToken.tokenString).to.equal(@"ACCESS_TOKEN");
            expect(request.action).to.equal(@"relation:query");
            expect(request.payload).to.equal(@{
                @"name" : @"follow",
                @"direction" : @"mutual",
            });
        });

        it(@"make request", ^{
            SKYQueryUsersOperation *operation = [[SKYQueryUsersOperation alloc]
                initWithEmails:@[ @"john.doe@example.com", @"jane.doe@example.com" ]];

            [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
                return YES;
            }
                withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
                    NSDictionary *parameters = @{
                        @"result" : @[
                            @{
                               @"id" : @"user0",
                               @"type" : @"user",
                               @"data" : @{
                                   @"_id" : @"user0",
                                   @"email" : @"john.doe@example.com",
                               },
                            },
                            @{
                               @"id" : @"user1",
                               @"type" : @"user",
                               @"data" : @{
                                   @"_id" : @"user1",
                                   @"email" : @"jane.doe@example.com",
                               },
                            },
                        ],
                        @"info" : @{@"count" : @10}
                    };
                    NSData *payload =
                        [NSJSONSerialization dataWithJSONObject:parameters options:0 error:nil];

                    return
                        [OHHTTPStubsResponse responseWithData:payload statusCode:200 headers:@{}];
                }];

            waitUntil(^(DoneCallback done) {
                __weak SKYQueryUsersOperation *weakOperation = operation;
                operation.queryUserCompletionBlock =
                    ^(NSArray<SKYUser *> *users, NSError *operationError) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            expect(users).to.haveCountOf(2);
                            expect(users[0].userID).to.equal(@"user0");
                            expect(users[1].userID).to.equal(@"user1");
                            expect(weakOperation.overallCount).to.equal(10);
                            expect(operationError).to.beNil();
                            done();
                        });
                    };

                [container addOperation:operation];
            });
        });

        it(@"not found", ^{
            SKYQueryUsersOperation *operation = [[SKYQueryUsersOperation alloc]
                initWithEmails:@[ @"john.doe@example.com", @"jane.doe@example.com" ]];

            [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
                return YES;
            }
                withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
                    NSDictionary *parameters = @{
                        @"result" : @[
                            @{
                               @"id" : @"user0",
                               @"type" : @"user",
                               @"data" : @{
                                   @"_id" : @"user0",
                                   @"email" : @"john.doe@example.com",
                               },
                            },
                        ],
                        @"info" : @{@"count" : @1}
                    };
                    NSData *payload =
                        [NSJSONSerialization dataWithJSONObject:parameters options:0 error:nil];

                    return
                        [OHHTTPStubsResponse responseWithData:payload statusCode:200 headers:@{}];
                }];

            waitUntil(^(DoneCallback done) {
                operation.queryUserCompletionBlock =
                    ^(NSArray<SKYUser *> *users, NSError *operationError) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            expect(users).to.haveCountOf(1);
                            expect(users[0].userID).to.equal(@"user0");
                            expect(operationError).notTo.beNil();
                            expect(operationError.code).to.equal(SKYErrorPartialFailure);
                            expect(operationError.userInfo[SKYPartialEmailsNotFoundKey]).to.equal(@[
                                @"jane.doe@example.com"
                            ]);
                            done();
                        });
                    };

                [container addOperation:operation];
            });
        });
    });

SpecEnd
