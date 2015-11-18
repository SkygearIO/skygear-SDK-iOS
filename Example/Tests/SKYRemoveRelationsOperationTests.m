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

SpecBegin(SKYRemoveRelationsOperation)

    describe(@"relation add", ^{
        __block SKYUser *follower1 = nil;
        __block SKYUser *follower2 = nil;
        __block SKYContainer *container = nil;

        beforeEach(^{
            container = [[SKYContainer alloc] init];
            [container updateWithUserRecordID:[SKYUserRecordID recordIDWithUsername:@"USER_ID"]
                                  accessToken:[[SKYAccessToken alloc]
                                                  initWithTokenString:@"ACCESS_TOKEN"]];
            SKYUserRecordID *userRecordID = [SKYUserRecordID recordIDWithUsername:@"user1001"];
            follower1 = [[SKYUser alloc] initWithUserRecordID:userRecordID];
            userRecordID = [SKYUserRecordID recordIDWithUsername:@"user1002"];
            follower2 = [[SKYUser alloc] initWithUserRecordID:userRecordID];
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
            expect(request.accessToken).to.equal(container.currentAccessToken);

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
                            expect(deletedUserIDs[0]).to.equal(follower1.recordID);
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
