//
//  SKYDatabaseTest.m
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

SpecBegin(SKYDatabase)

    describe(@"database", ^{
        __block SKYContainer *container;
        __block SKYDatabase *database;

        beforeEach(^{
            container = [SKYContainer testContainer];
            database = [container publicCloudDatabase];
        });

        it(@"fetch record", ^{
            NSString *bookTitle = @"A tale of two cities";
            [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
                return YES;
            }
                withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
                    NSDictionary *parameters = @{
                        @"request_id" : @"REQUEST_ID",
                        @"database_id" : database.databaseID,
                        @"result" : @[
                            @{
                                @"_recordType" : @"book",
                                @"_recordID" : @"book1",
                                @"_type" : @"record",
                                @"title" : bookTitle,
                            },
                        ]
                    };
                    NSData *payload =
                        [NSJSONSerialization dataWithJSONObject:parameters options:0 error:nil];

                    return
                        [OHHTTPStubsResponse responseWithData:payload statusCode:200 headers:@{}];
                }];

            waitUntil(^(DoneCallback done) {
                [database fetchRecordWithType:@"book"
                                     recordID:@"book1"
                                   completion:^(SKYRecord *record, NSError *error) {
                                       dispatch_async(dispatch_get_main_queue(), ^{
                                           expect(record.recordID).to.equal(@"book1");
                                           expect(record.recordType).to.equal(@"book");
                                           expect(record[@"title"]).to.equal(bookTitle);
                                           done();
                                       });
                                   }];
            });

        });

        it(@"fetch record with operation error", ^{
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
                [database fetchRecordWithType:@"book"
                                     recordID:@"book1"
                                   completion:^(SKYRecord *record, NSError *error) {
                                       dispatch_async(dispatch_get_main_queue(), ^{
                                           expect(error).notTo.beNil();
                                           expect(error.domain).to.equal(SKYOperationErrorDomain);
                                           expect(error.code).to.equal(SKYErrorNetworkFailure);
                                           done();
                                       });
                                   }];
            });

        });

        it(@"fetch records", ^{
            NSString *bookTitle = @"A tale of two cities";
            [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
                return YES;
            }
                withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
                    NSDictionary *parameters = @{
                        @"request_id" : @"REQUEST_ID",
                        @"database_id" : database.databaseID,
                        @"result" : @[
                            @{
                                @"_recordType" : @"book",
                                @"_recordID" : @"book1",
                                @"_type" : @"record",
                                @"title" : bookTitle,
                            },
                            @{
                                @"_recordType" : @"book",
                                @"_recordID" : @"book2",
                                @"_type" : @"error",
                                @"code" : @(SKYErrorUnexpectedError),
                                @"message" : @"An error.",
                                @"name" : @"UnexpectedError",
                            },
                        ]
                    };
                    NSData *payload =
                        [NSJSONSerialization dataWithJSONObject:parameters options:0 error:nil];

                    return
                        [OHHTTPStubsResponse responseWithData:payload statusCode:200 headers:@{}];
                }];

            waitUntil(^(DoneCallback done) {
                [database fetchRecordsWithType:@"book"
                                     recordIDs:@[ @"book1", @"book2" ]
                                    completion:^(
                                        NSArray<SKYRecordResult<SKYRecord *> *> *_Nullable results,
                                        NSError *_Nullable operationError) {
                                        expect(results[0].value.recordID).to.equal(@"book1");
                                        expect(results[1].error).notTo.beNil();
                                        expect(results).to.haveCountOf(2);
                                        done();
                                    }];
            });

        });

        it(@"modify record", ^{
            NSString *bookTitle = @"A tale of two cities";
            SKYRecord *record = [[SKYRecord alloc] initWithType:@"book" recordID:@"book1" data:nil];
            record[@"title"] = bookTitle;

            [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
                return YES;
            }
                withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
                    NSDictionary *parameters = @{
                        @"request_id" : @"REQUEST_ID",
                        @"database_id" : database.databaseID,
                        @"result" : @[
                            @{
                                @"_recordType" : @"book",
                                @"_recordID" : @"book1",
                                @"_type" : @"record",
                                @"_revision" : @"revision1",
                            },
                        ]
                    };
                    NSData *payload =
                        [NSJSONSerialization dataWithJSONObject:parameters options:0 error:nil];

                    return
                        [OHHTTPStubsResponse responseWithData:payload statusCode:200 headers:@{}];
                }];

            waitUntil(^(DoneCallback done) {
                [database saveRecord:record
                          completion:^(SKYRecord *record, NSError *error) {
                              dispatch_async(dispatch_get_main_queue(), ^{
                                  expect(record.recordID).to.equal(@"book1");
                                  expect(record.recordType).to.equal(@"book");
                                  done();
                              });
                          }];
            });

        });

        it(@"modify record with operation error", ^{
            NSString *bookTitle = @"A tale of two cities";
            SKYRecord *record = [[SKYRecord alloc] initWithType:@"book" recordID:@"book1"];
            record[@"title"] = bookTitle;

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
                [database saveRecord:record
                          completion:^(SKYRecord *record, NSError *error) {
                              dispatch_async(dispatch_get_main_queue(), ^{
                                  expect(error).notTo.beNil();
                                  expect(error.domain).to.equal(SKYOperationErrorDomain);
                                  expect(error.code).to.equal(SKYErrorNetworkFailure);
                                  done();
                              });
                          }];
            });
        });

        it(@"modify records", ^{
            NSString *bookTitle = @"A tale of two cities";
            SKYRecord *record1 = [[SKYRecord alloc] initWithType:@"book" recordID:@"book1"];
            record1[@"title"] = bookTitle;
            SKYRecord *record2 = [[SKYRecord alloc] initWithType:@"book" recordID:@"book2"];
            record2[@"title"] = bookTitle;

            [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
                return YES;
            }
                withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
                    NSDictionary *parameters = @{
                        @"request_id" : @"REQUEST_ID",
                        @"database_id" : database.databaseID,
                        @"result" : @[
                            @{
                                @"_recordType" : @"book",
                                @"_recordID" : @"book1",
                                @"_type" : @"record",
                                @"_revision" : @"revision1",
                            },
                            @{
                                @"_recordType" : @"book",
                                @"_recordID" : @"book2",
                                @"_type" : @"error",
                                @"code" : @(SKYErrorUnexpectedError),
                                @"message" : @"An error.",
                                @"name" : @"UnexpectedError",
                            },
                        ]
                    };
                    NSData *payload =
                        [NSJSONSerialization dataWithJSONObject:parameters options:0 error:nil];

                    return
                        [OHHTTPStubsResponse responseWithData:payload statusCode:200 headers:@{}];
                }];

            waitUntil(^(DoneCallback done) {
                [database
                    saveRecordsNonAtomically:@[ record1, record2 ]
                                  completion:^(
                                      NSArray<SKYRecordResult<SKYRecord *> *> *_Nonnull results,
                                      NSError *_Nullable operationError) {
                                      expect(results).to.haveCountOf(2);
                                      expect(results[0].value.recordID).to.equal(record1.recordID);
                                      expect(results[1].error).notTo.beNil();
                                      done();
                                  }];
            });

        });

        it(@"delete record", ^{
            [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
                return YES;
            }
                withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
                    NSDictionary *parameters = @{
                        @"request_id" : @"REQUEST_ID",
                        @"database_id" : database.databaseID,
                        @"result" : @[ @{
                            @"_recordType" : @"book",
                            @"_recordID" : @"book1",
                            @"_type" : @"record"
                        } ]
                    };
                    NSData *payload =
                        [NSJSONSerialization dataWithJSONObject:parameters options:0 error:nil];

                    return
                        [OHHTTPStubsResponse responseWithData:payload statusCode:200 headers:@{}];
                }];

            waitUntil(^(DoneCallback done) {
                [database deleteRecordWithType:@"book"
                                      recordID:@"book1"
                                    completion:^(NSString *recordID, NSError *error) {
                                        dispatch_async(dispatch_get_main_queue(), ^{
                                            expect(recordID).to.equal(@"book1");
                                            done();
                                        });
                                    }];
            });

        });

        it(@"delete record with operation error", ^{
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
                [database deleteRecordWithType:@"book"
                                      recordID:@"book1"
                                    completion:^(NSString *recordID, NSError *error) {
                                        dispatch_async(dispatch_get_main_queue(), ^{
                                            expect(error).notTo.beNil();
                                            expect(error.domain).to.equal(SKYOperationErrorDomain);
                                            expect(error.code).to.equal(SKYErrorNetworkFailure);
                                            done();
                                        });
                                    }];
            });
        });

        it(@"delete records", ^{
            NSString *recordID1 = @"book1";
            NSString *recordID2 = @"book2";

            [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
                return YES;
            }
                withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
                    NSDictionary *parameters = @{
                        @"request_id" : @"REQUEST_ID",
                        @"database_id" : database.databaseID,
                        @"result" : @[
                            @{
                                @"_recordType" : @"book",
                                @"_recordID" : @"book1",
                                @"_type" : @"record"
                            },
                            @{
                                @"_recordType" : @"book",
                                @"_recordID" : @"book2",
                                @"_type" : @"error",
                                @"code" : @(SKYErrorUnexpectedError),
                                @"message" : @"An error.",
                                @"name" : @"UnexpectedError",
                            }
                        ]
                    };
                    NSData *payload =
                        [NSJSONSerialization dataWithJSONObject:parameters options:0 error:nil];

                    return
                        [OHHTTPStubsResponse responseWithData:payload statusCode:200 headers:@{}];
                }];

            waitUntil(^(DoneCallback done) {
                [database
                    deleteRecordsNonAtomicallyWithType:@"book"
                                             recordIDs:@[ recordID1, recordID2 ]
                                            completion:^(NSArray<SKYRecordResult<NSString *> *>
                                                             *_Nullable results,
                                                         NSError *_Nullable error) {
                                                expect(results).to.haveCountOf(2);
                                                expect(results[0].value).to.equal(recordID1);
                                                expect(results[1].error).toNot.beNil();
                                                done();
                                            }];
            });

        });

        it(@"perform query", ^{
            [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
                return YES;
            }
                withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
                    NSDictionary *parameters = @{
                        @"request_id" : @"REQUEST_ID",
                        @"database_id" : database.databaseID,
                        @"result" : @[
                            @{
                                @"_recordType" : @"book",
                                @"_recordID" : @"book1",
                                @"_type" : @"record",
                                @"title" : @"A tale of two cities",
                            },
                        ]
                    };
                    NSData *payload =
                        [NSJSONSerialization dataWithJSONObject:parameters options:0 error:nil];

                    return
                        [OHHTTPStubsResponse responseWithData:payload statusCode:200 headers:@{}];
                }];

            waitUntil(^(DoneCallback done) {
                SKYQuery *query = [[SKYQuery alloc] initWithRecordType:@"book" predicate:nil];
                [database performQuery:query
                            completion:^(NSArray *results, NSError *error) {
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    expect(results).to.haveCountOf(1);
                                    expect(((SKYRecord *)results[0]).recordType).to.equal(@"book");
                                    expect(((SKYRecord *)results[0]).recordID).to.equal(@"book1");
                                    done();
                                });
                            }];
            });

        });

        it(@"perform query with operation error", ^{
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
                SKYQuery *query = [[SKYQuery alloc] initWithRecordType:@"book" predicate:nil];
                [database performQuery:query
                            completion:^(NSArray *results, NSError *error) {
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    expect(error).notTo.beNil();
                                    expect(error.domain).to.equal(SKYOperationErrorDomain);
                                    expect(error.code).to.equal(SKYErrorNetworkFailure);
                                    done();
                                });
                            }];
            });
        });

        it(@"fetch all subscriptions", ^{
            [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
                return YES;
            }
                withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
                    NSDictionary *parameters = @{
                        @"request_id" : @"REQUEST_ID",
                        @"database_id" : database.databaseID,
                        @"result" : @[
                            @{
                                @"id" : @"sub1",
                                @"type" : @"query",
                                @"query" : @{
                                    @"record_type" : @"book",
                                }
                            },
                            @{
                                @"id" : @"sub2",
                                @"type" : @"query",
                                @"query" : @{
                                    @"record_type" : @"book",
                                }
                            },
                        ]
                    };
                    NSData *payload =
                        [NSJSONSerialization dataWithJSONObject:parameters options:0 error:nil];

                    return
                        [OHHTTPStubsResponse responseWithData:payload statusCode:200 headers:@{}];
                }];

            waitUntil(^(DoneCallback done) {
                [database fetchAllSubscriptionsWithCompletionHandler:^(NSArray *subscriptions,
                                                                       NSError *error) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        expect([subscriptions count]).to.equal(2);

                        NSMutableArray *expectedSubscriptionIDs =
                            [@[ @"sub1", @"sub2" ] mutableCopy];
                        [subscriptions
                            enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                                [expectedSubscriptionIDs
                                    removeObject:((SKYSubscription *)obj).subscriptionID];
                            }];
                        expect([expectedSubscriptionIDs count]).to.equal(0);
                        done();
                    });
                }];
            });

        });
    });

SpecEnd
