//
//  SKYQueryOperationTests.m
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

SpecBegin(SKYQueryOperation)

    describe(@"fetch", ^{
        __block SKYContainer *container = nil;
        __block SKYDatabase *database = nil;

        beforeEach(^{
            container = [SKYContainer testContainer];
            [container.auth updateWithUserRecordID:@"USER_ID"
                                       accessToken:[[SKYAccessToken alloc] initWithTokenString:@"ACCESS_TOKEN"]];
            database = [container publicCloudDatabase];
        });

        it(@"empty predicate", ^{
            SKYQuery *query = [[SKYQuery alloc] initWithRecordType:@"book" predicate:nil];
            query.limit = 10;
            query.offset = 100;
            SKYQueryOperation *operation = [SKYQueryOperation operationWithQuery:query];
            SKYDatabase *database = [[SKYContainer defaultContainer] publicCloudDatabase];
            operation.container = container;
            operation.database = database;
            [operation makeURLRequestWithError:nil];
            SKYRequest *request = operation.request;
            expect([request class]).to.beSubclassOf([SKYRequest class]);
            expect(request.action).to.equal(@"record:query");
            expect(request.APIKey).to.equal(@"API_KEY");
            expect(request.accessToken).to.equal(container.auth.currentAccessToken);
            expect(request.payload[@"record_type"]).to.equal(@"book");
            expect(request.payload[@"database_id"]).to.equal(database.databaseID);
            expect(request.payload[@"predicate"]).to.equal(nil);
            expect(request.payload[@"limit"]).to.equal(10);
            expect(request.payload[@"offset"]).to.equal(100);
        });

        it(@"simple query", ^{
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name = %@", @"A tale of two cities"];
            SKYQuery *query = [[SKYQuery alloc] initWithRecordType:@"book" predicate:predicate];
            SKYQueryOperation *operation = [SKYQueryOperation operationWithQuery:query];
            SKYDatabase *database = [[SKYContainer defaultContainer] publicCloudDatabase];
            operation.container = container;
            operation.database = database;
            [operation makeURLRequestWithError:nil];
            SKYRequest *request = operation.request;
            expect([request class]).to.beSubclassOf([SKYRequest class]);
            expect(request.action).to.equal(@"record:query");
            expect(request.APIKey).to.equal(@"API_KEY");
            expect(request.accessToken).to.equal(container.auth.currentAccessToken);
            expect(request.payload[@"record_type"]).to.equal(@"book");
            expect(request.payload[@"database_id"]).to.equal(database.databaseID);

            NSArray *predicateArray = request.payload[@"predicate"];
            expect([predicateArray class]).to.beSubclassOf([NSArray class]);
            expect(predicateArray[0]).to.equal(@"eq");
            expect(predicateArray[1]).to.equal(@{@"$type" : @"keypath", @"$val" : @"name"});
            expect(predicateArray[2]).to.equal(@"A tale of two cities");
        });

        it(@"sorted", ^{
            SKYQuery *query = [[SKYQuery alloc] initWithRecordType:@"book" predicate:nil];
            query.sortDescriptors = @[ [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES] ];
            SKYQueryOperation *operation = [SKYQueryOperation operationWithQuery:query];
            SKYDatabase *database = [[SKYContainer defaultContainer] publicCloudDatabase];
            operation.container = container;
            operation.database = database;
            [operation makeURLRequestWithError:nil];
            SKYRequest *request = operation.request;

            expect(request.payload[@"sort"][0]).to.equal(@[ @{@"$type" : @"keypath", @"$val" : @"name"}, @"asc" ]);
        });

        it(@"transient", ^{
            SKYQuery *query = [[SKYQuery alloc] initWithRecordType:@"book" predicate:nil];
            query.transientIncludes = @{@"shelf" : [NSExpression expressionForKeyPath:@"shelf"]};
            SKYQueryOperation *operation = [SKYQueryOperation operationWithQuery:query];
            SKYDatabase *database = [[SKYContainer defaultContainer] publicCloudDatabase];
            operation.container = container;
            operation.database = database;
            [operation makeURLRequestWithError:nil];
            SKYRequest *request = operation.request;

            expect(request.payload[@"include"]).to.equal(@{@"shelf" : @{@"$type" : @"keypath", @"$val" : @"shelf"}});
        });

        it(@"make request", ^{
            SKYQuery *query = [[SKYQuery alloc] initWithRecordType:@"book" predicate:nil];
            SKYQueryOperation *operation = [SKYQueryOperation operationWithQuery:query];
            SKYDatabase *database = [[SKYContainer defaultContainer] publicCloudDatabase];
            operation.database = database;

            [OHHTTPStubs
                stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
                    return YES;
                }
                withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
                    NSDictionary *parameters = @{
                        @"request_id" : @"REQUEST_ID",
                        @"database_id" : database.databaseID,
                        @"info" : @{@"count" : @2},
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
                    NSData *payload = [NSJSONSerialization dataWithJSONObject:parameters options:0 error:nil];

                    return [OHHTTPStubsResponse responseWithData:payload statusCode:200 headers:@{}];
                }];

            waitUntil(^(DoneCallback done) {
                __weak SKYQueryOperation *weakOperation = operation;
                operation.queryRecordsCompletionBlock =
                    ^(NSArray *fetchedRecords, SKYQueryCursor *cursor, NSError *operationError) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            expect([fetchedRecords class]).to.beSubclassOf([NSArray class]);
                            expect(fetchedRecords).to.haveCountOf(2);
                            expect([[fetchedRecords[0] recordID] recordName]).to.equal(@"book1");
                            expect([[fetchedRecords[1] recordID] recordName]).to.equal(@"book2");
                            expect(weakOperation.overallCount).to.equal(2);
                            done();
                        });
                    };

                [container addOperation:operation];
            });
        });

        it(@"pass error", ^{
            SKYQuery *query = [[SKYQuery alloc] initWithRecordType:@"book" predicate:nil];
            SKYQueryOperation *operation = [[SKYQueryOperation alloc] initWithQuery:query];
            [OHHTTPStubs
                stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
                    return YES;
                }
                withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
                    return [OHHTTPStubsResponse
                        responseWithError:[NSError errorWithDomain:NSURLErrorDomain code:0 userInfo:nil]];
                }];

            waitUntil(^(DoneCallback done) {
                operation.queryRecordsCompletionBlock =
                    ^(NSArray *fetchedRecords, SKYQueryCursor *cursor, NSError *operationError) {
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
            SKYQuery *query = [[SKYQuery alloc] initWithRecordType:@"book" predicate:nil];
            SKYQueryOperation *operation = [[SKYQueryOperation alloc] initWithQuery:query];

            [OHHTTPStubs
                stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
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
                                @"_type" : @"unknown",
                            },
                        ]
                    };
                    NSData *payload = [NSJSONSerialization dataWithJSONObject:parameters options:0 error:nil];

                    return [OHHTTPStubsResponse responseWithData:payload statusCode:200 headers:@{}];
                }];

            waitUntil(^(DoneCallback done) {
                NSMutableArray *remainingRecordIDs = [@[ recordID1 ] mutableCopy];
                operation.perRecordCompletionBlock = ^(SKYRecord *record) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        expect(record).toNot.beNil();
                        SKYRecordID *recordID = record.recordID;
                        if ([recordID isEqual:recordID1]) {
                            expect([record class]).to.beSubclassOf([SKYRecord class]);
                            expect(record.recordID).to.equal(recordID1);
                        }
                        [remainingRecordIDs removeObject:recordID];
                    });
                };

                operation.queryRecordsCompletionBlock =
                    ^(NSArray *fetchedRecords, SKYQueryCursor *cursor, NSError *operationError) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            expect(remainingRecordIDs).to.haveCountOf(0);
                            done();
                        });
                    };

                [database executeOperation:operation];
            });
        });

        it(@"per block with eager load", ^{
            SKYRecordID *recordID1 = [[SKYRecordID alloc] initWithRecordType:@"book" name:@"book1"];
            SKYQuery *query = [[SKYQuery alloc] initWithRecordType:@"book" predicate:nil];
            query.transientIncludes = @{@"category" : [NSExpression expressionForKeyPath:@"category"]};
            SKYQueryOperation *operation = [SKYQueryOperation operationWithQuery:query];

            [OHHTTPStubs
                stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
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
                                @"category" : @{@"$type" : @"ref", @"$id" : @"category/important"},
                                @"_transient" : @{
                                    @"category" : @{
                                        @"_id" : @"category/important",
                                        @"_type" : @"record",
                                        @"title" : @"Important",
                                    }

                                }
                            },
                        ],
                    };
                    NSData *payload = [NSJSONSerialization dataWithJSONObject:parameters options:0 error:nil];

                    return [OHHTTPStubsResponse responseWithData:payload statusCode:200 headers:@{}];
                }];

            waitUntil(^(DoneCallback done) {
                NSMutableArray *remainingRecordIDs = [@[ recordID1 ] mutableCopy];
                operation.perRecordCompletionBlock = ^(SKYRecord *record) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        expect(record).toNot.beNil();
                        SKYRecordID *recordID = record.recordID;
                        if ([recordID isEqual:recordID1]) {
                            expect([record class]).to.beSubclassOf([SKYRecord class]);
                            expect(record.recordID).to.equal(recordID1);
                        }
                        SKYRecord *categoryRecord = record.transient[@"category"];
                        expect([categoryRecord class]).to.beSubclassOf([SKYRecord class]);
                        expect(categoryRecord[@"title"]).to.equal(@"Important");
                        [remainingRecordIDs removeObject:recordID];
                    });
                };

                operation.queryRecordsCompletionBlock =
                    ^(NSArray *fetchedRecords, SKYQueryCursor *cursor, NSError *operationError) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            expect(remainingRecordIDs).to.haveCountOf(0);
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
