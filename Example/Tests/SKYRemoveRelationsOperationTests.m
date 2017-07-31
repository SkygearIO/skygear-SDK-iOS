//
//  SKYRemoveRelationsOperationTests.m
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

SpecBegin(SKYRemoveRelationsOperation)

    describe(@"relation add", ^{
        __block SKYRecord *follower1 = nil;
        __block SKYRecord *follower2 = nil;
        __block SKYContainer *container = nil;

        beforeEach(^{
            container = [[SKYContainer alloc] init];
            [container.auth updateWithUserRecordID:@"USER_ID"
                                       accessToken:[[SKYAccessToken alloc]
                                                       initWithTokenString:@"ACCESS_TOKEN"]];
            NSString *userRecordID = @"user1001";
            follower1 = [SKYRecord recordWithRecordType:@"user" name:userRecordID];
            userRecordID = @"user1002";
            follower2 = [SKYRecord recordWithRecordType:@"user" name:userRecordID];
        });

        it(@"multiple relations", ^{
            SKYRemoveRelationsOperation *operation =
                [SKYRemoveRelationsOperation operationWithType:@"follow"
                                                 usersToRemove:@[ follower1, follower2 ]];
            operation.container = container;
            [operation prepareForRequest];
            SKYRequest *request = operation.request;
            expect([request class]).to.beSubclassOf([SKYRequest class]);
            expect(request.action).to.equal(@"relation:delete");
            expect(request.payload[@"name"]).to.equal(@"follow");
            expect(request.payload[@"targets"]).to.haveCountOf(2);
            expect(request.accessToken).to.equal(container.auth.currentAccessToken);

            expect(request.payload[@"targets"][0]).to.equal(@"user1001");
            expect(request.payload[@"targets"][1]).to.equal(@"user1002");
        });

        it(@"make request", ^{
            SKYRemoveRelationsOperation *operation =
                [SKYRemoveRelationsOperation operationWithType:@"follow"
                                                 usersToRemove:@[ follower1, follower2 ]];

            [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
                return YES;
            }
                withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
                    NSDictionary *parameters = @{
                        @"request_id" : @"REQUEST_ID",
                        @"result" : @[
                            @{
                                @"id" : @"user1001",
                            },
                            @{
                                @"id" : @"user1002",
                                @"type" : @"error",
                                @"data" : @{
                                    @"message" : @"cannot find user",
                                    @"code" : @"ResourceNotFound",
                                },
                            }
                        ]
                    };
                    NSData *payload =
                        [NSJSONSerialization dataWithJSONObject:parameters options:0 error:nil];

                    return
                        [OHHTTPStubsResponse responseWithData:payload statusCode:200 headers:@{}];
                }];

            waitUntil(^(DoneCallback done) {
                operation.removeRelationsCompletionBlock =
                    ^(NSArray *deletedUserIDs, NSError *operationError) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            expect([deletedUserIDs class]).to.beSubclassOf([NSArray class]);
                            expect(deletedUserIDs).to.haveCountOf(1);
                            expect(deletedUserIDs[0]).to.equal(follower1.recordID.recordName);
                            expect(operationError).toNot.beNil();
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
