//
//  SKYDiscoverUsersOperationTests.m
//  SkyKit
//
//  Created by Kenji Pa on 1/6/15.
//  Copyright (c) 2015 Kwok-kuen Cheung. All rights reserved.
//

#import <SkyKit/SkyKit.h>
#import <OHHTTPStubs/OHHTTPStubs.h>

SpecBegin(SKYDiscoverUsersOperation)

    describe(@"discover", ^{
        __block SKYContainer *container = nil;

        beforeEach(^{
            container = [[SKYContainer alloc] init];
            [container updateWithUserRecordID:[SKYUserRecordID recordIDWithUsername:@"USER_ID"]
                                  accessToken:[[SKYAccessToken alloc]
                                                  initWithTokenString:@"ACCESS_TOKEN"]];
        });

        it(@"multiple emails", ^{
            SKYQueryUsersOperation *operation =
                [SKYQueryUsersOperation discoverUsersOperationByEmails:
                                            @[ @"john.doe@example.com", @"jane.doe@example.com" ]];
            operation.container = container;
            [operation prepareForRequest];
            SKYRequest *request = operation.request;
            expect([request class]).to.beSubclassOf([SKYRequest class]);
            expect(request.action).to.equal(@"user:query");
            expect(request.accessToken.tokenString).to.equal(@"ACCESS_TOKEN");
            expect(request.payload)
                .to.equal(@{
                    @"emails" : @[ @"john.doe@example.com", @"jane.doe@example.com" ],
                });
        });

        it(@"query relation", ^{
            SKYQueryUsersOperation *operation =
                [SKYQueryUsersOperation queryUsersOperationByRelation:[SKYRelation relationFollow]
                                                            direction:SKYRelationDirectionMutual];
            operation.container = container;
            [operation prepareForRequest];

            SKYRequest *request = operation.request;
            expect([request class]).to.beSubclassOf([SKYRequest class]);
            expect(request.accessToken.tokenString).to.equal(@"ACCESS_TOKEN");
            expect(request.action).to.equal(@"relation:query");
            expect(request.payload)
                .to.equal(@{
                    @"name" : @"follow",
                    @"direction" : @"mutual",
                });
        });

        it(@"make request", ^{
            SKYQueryUsersOperation *operation = [[SKYQueryUsersOperation alloc]
                initWithEmails:@[ @"john.doe@example.com", @"jane.doe@example.com" ]];

            [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
                return YES;
            } withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
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

                return [OHHTTPStubsResponse responseWithData:payload statusCode:200 headers:@{}];
            }];

            waitUntil(^(DoneCallback done) {
                operation.queryUserCompletionBlock = ^(NSArray *users, NSError *operationError) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        expect(users).to.haveCountOf(2);
                        expect([users[0] username]).to.equal(@"user0");
                        expect([users[1] username]).to.equal(@"user1");
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
            } withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
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

                return [OHHTTPStubsResponse responseWithData:payload statusCode:200 headers:@{}];
            }];

            waitUntil(^(DoneCallback done) {
                operation.queryUserCompletionBlock = ^(NSArray *users, NSError *operationError) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        expect(users).to.haveCountOf(1);
                        expect([users[0] username]).to.equal(@"user0");
                        expect(operationError).notTo.beNil();
                        expect(operationError.code).to.equal(SKYErrorPartialFailure);
                        expect(operationError.userInfo)
                            .to.equal(@{
                                SKYPartialEmailsNotFoundKey : @[ @"jane.doe@example.com" ],
                            });
                        done();
                    });
                };

                [container addOperation:operation];
            });
        });
    });

SpecEnd
