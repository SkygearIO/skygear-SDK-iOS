//
//  SKYAddRelationsOperationTests.m
//  SkyKit
//
//  Created by Rick Mak on 19/5/15.
//  Copyright (c) 2015 Kwok-kuen Cheung. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SkyKit/SkyKit.h>
#import <OHHTTPStubs/OHHTTPStubs.h>

SpecBegin(SKYAddRelationsOperation)

    describe(@"relation add", ^{
        __block SKYUser *follower1 = nil;
        __block SKYUser *follower2 = nil;
        __block SKYUser *follower3 = nil;
        __block SKYContainer *container = nil;

        beforeEach(^{
            container = [[SKYContainer alloc] init];
            [container updateWithUserRecordID:[SKYUserRecordID recordIDWithUsername:@"USER_ID"]
                                  accessToken:[[SKYAccessToken alloc]
                                                  initWithTokenString:@"ACCESS_TOKEN"]];
            SKYUserRecordID *userRecordID1 = [SKYUserRecordID recordIDWithUsername:@"user1001"];
            follower1 = [[SKYUser alloc] initWithUserRecordID:userRecordID1];
            SKYUserRecordID *userRecordID2 = [SKYUserRecordID recordIDWithUsername:@"user1002"];
            follower2 = [[SKYUser alloc] initWithUserRecordID:userRecordID2];
            SKYUserRecordID *userRecordID3 = [SKYUserRecordID recordIDWithUsername:@"user1003"];
            follower3 = [[SKYUser alloc] initWithUserRecordID:userRecordID3];
        });

        it(@"multiple relations", ^{
            SKYAddRelationsOperation *operation =
                [SKYAddRelationsOperation operationWithType:@"follow"
                                             usersToRelated:@[ follower1, follower2 ]];
            operation.container = container;
            [operation prepareForRequest];
            SKYRequest *request = operation.request;
            expect([request class]).to.beSubclassOf([SKYRequest class]);
            expect(request.action).to.equal(@"relation:add");
            expect(request.payload[@"name"]).to.equal(@"follow");
            expect(request.payload[@"targets"]).to.haveCountOf(2);
            expect(request.accessToken).to.equal(container.currentAccessToken);

            expect(request.payload[@"targets"][0]).to.equal(@"user1001");
            expect(request.payload[@"targets"][1]).to.equal(@"user1002");
        });

        it(@"make request", ^{
            SKYAddRelationsOperation *operation =
                [SKYAddRelationsOperation operationWithType:@"follow"
                                             usersToRelated:@[ follower1, follower2, follower3 ]];

            [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
                return YES;
            } withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
                NSDictionary *parameters = @{
                    @"request_id" : @"REQUEST_ID",
                    @"result" : @[
                        @{
                           @"id" : @"user1001",
                           @"type" : @"user",
                           @"data" : @{
                               @"_id" : @"user1001",
                               @"username" : @"user1001",
                               @"email" : @"user1001@skygear.io"
                           },
                        },
                        @{
                           @"id" : @"user1002",
                           @"type" : @"error",
                           @"data" : @{
                               @"code" : @104,
                               @"message" : @"cannot find user",
                               @"type" : @"ResourceNotFound",
                               @"info" : @{@"id" : @"user1002"},
                           },
                        },
                    ],
                };
                NSData *payload =
                    [NSJSONSerialization dataWithJSONObject:parameters options:0 error:nil];

                return [OHHTTPStubsResponse responseWithData:payload statusCode:200 headers:@{}];
            }];

            waitUntil(^(DoneCallback done) {
                operation.addRelationsCompletionBlock =
                    ^(NSArray *savedUsers, NSError *operationError) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            expect([savedUsers class]).to.beSubclassOf([NSArray class]);
                            expect(savedUsers).to.haveCountOf(1);
                            expect(savedUsers[0])
                                .to.equal([SKYUserRecordID recordIDWithUsername:@"user1001"]);
                            expect(operationError).toNot.beNil();
                            NSArray *errorKeys =
                                [operationError.userInfo[SKYPartialErrorsByItemIDKey] allKeys];
                            expect(errorKeys).to.contain(@"user1002");
                            expect(errorKeys).to.contain(@"user1003");
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
