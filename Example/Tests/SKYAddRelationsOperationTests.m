//
//  SKYAddRelationsOperationTests.m
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
#import <SKYKit/SKYKit.h>
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
            }
                withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
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
                                   @"code" : @(SKYErrorResourceNotFound),
                                   @"message" : @"cannot find user",
                                   @"name" : @"ResourceNotFound",
                                   @"info" : @{@"id" : @"user1002"},
                               },
                            },
                        ],
                    };
                    NSData *payload =
                        [NSJSONSerialization dataWithJSONObject:parameters options:0 error:nil];

                    return
                        [OHHTTPStubsResponse responseWithData:payload statusCode:200 headers:@{}];
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
