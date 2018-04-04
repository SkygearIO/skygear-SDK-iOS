//
//  SKYFetchRecordsOperationTests.m
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

SpecBegin(SKYFetchRecordsOperation)

    describe(@"fetch", ^{
        __block SKYContainer *container = nil;
        __block SKYDatabase *database = nil;

        beforeEach(^{
            container = [SKYContainer testContainer];
            [container.auth updateWithUserRecordID:@"USER_ID"
                                       accessToken:[[SKYAccessToken alloc]
                                                       initWithTokenString:@"ACCESS_TOKEN"]];
            database = [container publicCloudDatabase];
        });

        it(@"single record", ^{
            SKYRecordID *recordID = [[SKYRecordID alloc] initWithRecordType:@"book" name:@"book1"];
            SKYFetchRecordsOperation *operation =
                [SKYFetchRecordsOperation operationWithRecordIDs:@[ recordID ]];
            operation.container = container;
            operation.database = database;
            [operation prepareForRequest];
            SKYRequest *request = operation.request;
            expect([request class]).to.beSubclassOf([SKYRequest class]);
            expect(request.action).to.equal(@"record:fetch");
            expect(request.APIKey).to.equal(@"API_KEY");
            expect(request.accessToken).to.equal(container.auth.currentAccessToken);
            expect(request.payload[@"ids"]).to.equal(@[ recordID.canonicalString ]);
            expect(request.payload[@"database_id"]).to.equal(database.databaseID);
            expect(request.payload).toNot.contain(@"desired_keys");
        });

        it(@"multiple record", ^{
            SKYRecordID *recordID1 = [[SKYRecordID alloc] initWithRecordType:@"book" name:@"book1"];
            SKYRecordID *recordID2 = [[SKYRecordID alloc] initWithRecordType:@"book" name:@"book2"];
            SKYFetchRecordsOperation *operation =
                [SKYFetchRecordsOperation operationWithRecordIDs:@[ recordID1, recordID2 ]];
            operation.container = container;
            operation.database = database;
            [operation prepareForRequest];
            SKYRequest *request = operation.request;
            expect([request class]).to.beSubclassOf([SKYRequest class]);
            expect(request.action).to.equal(@"record:fetch");
            expect(request.APIKey).to.equal(@"API_KEY");
            expect(request.accessToken).to.equal(container.auth.currentAccessToken);
            expect(request.payload[@"ids"]).to.equal(@[
                recordID1.canonicalString, recordID2.canonicalString
            ]);
            expect(request.payload[@"database_id"]).to.equal(database.databaseID);
            expect(request.payload).toNot.contain(@"desired_keys");
        });

        it(@"make request", ^{
            SKYRecordID *recordID1 = [[SKYRecordID alloc] initWithRecordType:@"book" name:@"book1"];
            SKYRecordID *recordID2 = [[SKYRecordID alloc] initWithRecordType:@"book" name:@"book2"];
            SKYFetchRecordsOperation *operation =
                [SKYFetchRecordsOperation operationWithRecordIDs:@[ recordID1, recordID2 ]];

            [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
                return YES;
            }
                withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
                    NSDictionary *parameters = @{
                        @"request_id" : @"REQUEST_ID",
                        @"database_id" : database.databaseID,
                        @"result" : @[
                            @{
                                @"_id" : @"book/book1",
                                @"_type" : @"record",
                                @"title" : @"A tale of two cities",
                            },
                            @{
                                @"_id" : @"book/book2",
                                @"_type" : @"record",
                                @"title" : @"Old man and the sea",
                            }
                        ]
                    };
                    NSData *payload =
                        [NSJSONSerialization dataWithJSONObject:parameters options:0 error:nil];

                    return
                        [OHHTTPStubsResponse responseWithData:payload statusCode:200 headers:@{}];
                }];

            waitUntil(^(DoneCallback done) {
                operation.fetchRecordsCompletionBlock =
                    ^(NSDictionary *recordsByRecordID, NSError *operationError) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            expect([recordsByRecordID class]).to.beSubclassOf([NSDictionary class]);
                            expect(recordsByRecordID).to.haveCountOf(2);
                            expect([recordsByRecordID[recordID1] recordID]).to.equal(recordID1);
                            expect([recordsByRecordID[recordID2] recordID]).to.equal(recordID2);
                            expect(operationError).to.beNil();
                            done();
                        });
                    };

                [database executeOperation:operation];
            });
        });

        it(@"pass error", ^{
            SKYRecordID *recordID1 = [[SKYRecordID alloc] initWithRecordType:@"book" name:@"book1"];
            SKYRecordID *recordID2 = [[SKYRecordID alloc] initWithRecordType:@"book" name:@"book2"];
            SKYFetchRecordsOperation *operation =
                [SKYFetchRecordsOperation operationWithRecordIDs:@[ recordID1, recordID2 ]];
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
                operation.fetchRecordsCompletionBlock =
                    ^(NSDictionary *recordsByRecordID, NSError *operationError) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            expect(operationError).toNot.beNil();
                            done();
                        });
                    };
                [database executeOperation:operation];
            });
        });

        it(@"per block", ^{
            SKYRecordID *recordID1 = [[SKYRecordID alloc] initWithRecordType:@"book" name:@"book1"];
            SKYRecordID *recordID2 = [[SKYRecordID alloc] initWithRecordType:@"book" name:@"book2"];
            SKYRecordID *recordID3 = [[SKYRecordID alloc] initWithRecordType:@"book" name:@"book3"];
            SKYFetchRecordsOperation *operation =
                [SKYFetchRecordsOperation operationWithRecordIDs:@[ recordID1, recordID2 ]];

            [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
                return YES;
            }
                withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
                    NSDictionary *parameters = @{
                        @"request_id" : @"REQUEST_ID",
                        @"database_id" : database.databaseID,
                        @"result" : @[
                            @{
                                @"_id" : @"book/book1",
                                @"_type" : @"record",
                                @"title" : @"A tale of two cities",
                            },
                            @{
                                @"_id" : @"book/book2",
                                @"_type" : @"error",
                                @"code" : @(SKYErrorResourceNotFound),
                                @"message" : @"An error.",
                                @"name" : @"ResourceNotFound",
                            },
                            @{
                                @"_id" : @"book/book3",
                                @"_type" : @"unknown",
                            },
                        ]
                    };
                    NSData *payload =
                        [NSJSONSerialization dataWithJSONObject:parameters options:0 error:nil];

                    return
                        [OHHTTPStubsResponse responseWithData:payload statusCode:200 headers:@{}];
                }];

            waitUntil(^(DoneCallback done) {
                NSMutableArray *remainingRecordIDs =
                    [@[ recordID1, recordID2, recordID3 ] mutableCopy];
                operation.perRecordCompletionBlock = ^(SKYRecord *record, SKYRecordID *recordID,
                                                       NSError *error) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if ([recordID isEqual:recordID1]) {
                            expect([record class]).to.beSubclassOf([SKYRecord class]);
                            expect(record.recordID).to.equal(recordID1);
                        } else if ([recordID isEqual:recordID2]) {
                            expect([error class]).to.beSubclassOf([NSError class]);
                            expect(error.userInfo[SKYErrorNameKey]).to.equal(@"ResourceNotFound");
                            expect(error.code).to.equal(SKYErrorResourceNotFound);
                            expect(error.userInfo[SKYErrorMessageKey]).to.equal(@"An error.");
                        } else if ([recordID isEqual:recordID3]) {
                            expect([error class]).to.beSubclassOf([NSError class]);
                        }
                        [remainingRecordIDs removeObject:recordID];
                    });
                };

                operation.fetchRecordsCompletionBlock =
                    ^(NSDictionary *recordsByRecordID, NSError *operationError) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            expect(remainingRecordIDs).to.haveCountOf(0);
                            expect(operationError.code).to.equal(SKYErrorPartialFailure);
                            NSDictionary *errorsByID =
                                operationError.userInfo[SKYPartialErrorsByItemIDKey];
                            expect(errorsByID).to.haveCountOf(1);
                            expect([errorsByID[recordID2] class]).to.beSubclassOf([NSError class]);
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
