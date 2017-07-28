//
//  SKYDeleteRecordsOperationTests.m
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

SpecBegin(SKYDeleteRecordsOperation)

    describe(@"delete", ^{
        __block SKYContainer *container = nil;
        __block SKYDatabase *database = nil;

        beforeEach(^{
            container = [[SKYContainer alloc] init];
            [container.auth updateWithUserRecordID:@"USER_ID"
                                       accessToken:[[SKYAccessToken alloc]
                                                       initWithTokenString:@"ACCESS_TOKEN"]];
            database = [container publicCloudDatabase];
        });

        it(@"single record", ^{
            SKYRecordID *recordID = [[SKYRecordID alloc] initWithRecordType:@"book" name:@"book1"];
            SKYDeleteRecordsOperation *operation =
                [SKYDeleteRecordsOperation operationWithRecordIDsToDelete:@[ recordID ]];
            operation.database = database;
            operation.container = container;
            [operation prepareForRequest];
            SKYRequest *request = operation.request;
            expect([request class]).to.beSubclassOf([SKYRequest class]);
            expect(request.action).to.equal(@"record:delete");
            expect(request.accessToken).to.equal(container.auth.currentAccessToken);
            expect(request.payload[@"ids"]).to.equal(@[ recordID.canonicalString ]);
            expect(request.payload[@"database_id"]).to.equal(database.databaseID);
        });

        it(@"multiple record", ^{
            SKYRecordID *recordID1 = [[SKYRecordID alloc] initWithRecordType:@"book" name:@"book1"];
            SKYRecordID *recordID2 = [[SKYRecordID alloc] initWithRecordType:@"book" name:@"book2"];
            SKYDeleteRecordsOperation *operation = [SKYDeleteRecordsOperation
                operationWithRecordIDsToDelete:@[ recordID1, recordID2 ]];
            operation.database = database;
            operation.container = container;
            [operation prepareForRequest];
            SKYRequest *request = operation.request;
            expect([request class]).to.beSubclassOf([SKYRequest class]);
            expect(request.action).to.equal(@"record:delete");
            expect(request.accessToken).to.equal(container.auth.currentAccessToken);
            expect(request.payload[@"ids"]).to.equal(@[
                recordID1.canonicalString, recordID2.canonicalString
            ]);
            expect(request.payload[@"database_id"]).to.equal(database.databaseID);
        });

        it(@"set atomic", ^{
            SKYDeleteRecordsOperation *operation =
                [SKYDeleteRecordsOperation operationWithRecordIDsToDelete:@[]];
            operation.atomic = YES;

            operation.database = database;
            operation.container = container;
            [operation prepareForRequest];

            SKYRequest *request = operation.request;
            expect(request.payload[@"atomic"]).to.equal(@YES);
        });

        it(@"make request", ^{
            SKYRecordID *recordID1 = [[SKYRecordID alloc] initWithRecordType:@"book" name:@"book1"];
            SKYRecordID *recordID2 = [[SKYRecordID alloc] initWithRecordType:@"book" name:@"book2"];
            SKYDeleteRecordsOperation *operation = [SKYDeleteRecordsOperation
                operationWithRecordIDsToDelete:@[ recordID1, recordID2 ]];

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
                            },
                            @{
                                @"_id" : @"book/book2",
                                @"_type" : @"record",
                            },
                        ],
                    };
                    NSData *payload =
                        [NSJSONSerialization dataWithJSONObject:parameters options:0 error:nil];

                    return
                        [OHHTTPStubsResponse responseWithData:payload statusCode:200 headers:@{}];
                }];

            waitUntil(^(DoneCallback done) {
                operation.deleteRecordsCompletionBlock =
                    ^(NSArray *recordIDs, NSError *operationError) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            expect(recordIDs).to.equal(@[ recordID1, recordID2 ]);
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
            SKYDeleteRecordsOperation *operation = [SKYDeleteRecordsOperation
                operationWithRecordIDsToDelete:@[ recordID1, recordID2 ]];
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
                operation.deleteRecordsCompletionBlock =
                    ^(NSArray *recordIDs, NSError *operationError) {
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
            SKYDeleteRecordsOperation *operation = [SKYDeleteRecordsOperation
                operationWithRecordIDsToDelete:@[ recordID1, recordID2 ]];

            [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
                return YES;
            }
                withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
                    NSDictionary *parameters = @{
                        @"request_id" : @"REQUEST_ID",
                        @"database_id" : database.databaseID,
                        @"result" : @[ @{
                            @"_id" : @"book/book2",
                            @"_type" : @"error",
                            @"code" : @(SKYErrorUnexpectedError),
                            @"message" : @"An error.",
                            @"name" : @"UnexpectedError",
                        } ]
                    };
                    NSData *payload =
                        [NSJSONSerialization dataWithJSONObject:parameters options:0 error:nil];

                    return
                        [OHHTTPStubsResponse responseWithData:payload statusCode:200 headers:@{}];
                }];

            waitUntil(^(DoneCallback done) {
                NSMutableArray *remaingRecordIDs = [@[ recordID1, recordID2 ] mutableCopy];
                operation.perRecordCompletionBlock = ^(SKYRecordID *recordID, NSError *error) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [remaingRecordIDs removeObject:recordID];
                    });
                };

                operation.deleteRecordsCompletionBlock =
                    ^(NSArray *recordIDs, NSError *operationError) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            expect(recordIDs).to.haveCountOf(1);
                            expect(remaingRecordIDs).to.haveCountOf(0);
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
