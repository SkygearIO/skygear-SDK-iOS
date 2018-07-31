//
//  SKYModifyRecordsOperationTests.m
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

SpecBegin(SKYModifyRecordsOperation)

    describe(@"modify", ^{
        __block SKYRecord *record1 = nil;
        __block SKYRecord *record2 = nil;
        __block SKYContainer *container = nil;
        __block SKYDatabase *database = nil;

        beforeEach(^{
            container = [SKYContainer testContainer];
            [container.auth updateWithUserRecordID:@"USER_ID"
                                       accessToken:[[SKYAccessToken alloc]
                                                       initWithTokenString:@"ACCESS_TOKEN"]];
            database = [container publicCloudDatabase];
            record1 = [[SKYRecord alloc] initWithType:@"book" recordID:@"book1"];
            record2 = [[SKYRecord alloc] initWithType:@"book" recordID:@"book2"];
        });

        it(@"multiple record", ^{
            SKYModifyRecordsOperation *operation =
                [SKYModifyRecordsOperation operationWithRecords:@[ record1, record2 ]];
            operation.container = container;
            operation.database = database;
            [operation makeURLRequestWithError:nil];
            SKYRequest *request = operation.request;
            expect([request class]).to.beSubclassOf([SKYRequest class]);
            expect(request.action).to.equal(@"record:save");
            expect(request.payload[@"records"]).to.haveCountOf(2);
            expect(request.accessToken).to.equal(container.auth.currentAccessToken);

            NSDictionary *recordPayload = request.payload[@"records"][0];
            expect(recordPayload[SKYRecordSerializationRecordIDKey]).to.equal(@"book/book1");
            recordPayload = request.payload[@"records"][1];
            expect(recordPayload[SKYRecordSerializationRecordIDKey]).to.equal(@"book/book2");
            expect(request.payload[@"database_id"]).to.equal(database.databaseID);
        });

        it(@"set atomic", ^{
            SKYModifyRecordsOperation *operation =
                [SKYModifyRecordsOperation operationWithRecords:@[ record1, record2 ]];
            operation.atomic = YES;

            operation.container = container;
            operation.database = database;
            [operation makeURLRequestWithError:nil];

            SKYRequest *request = operation.request;
            expect(request.payload[@"atomic"]).to.equal(@YES);
        });

        it(@"make request", ^{
            SKYModifyRecordsOperation *operation =
                [SKYModifyRecordsOperation operationWithRecords:@[ record1, record2 ]];

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
                                @"_type" : @"record",
                                @"_revision" : @"revision2",
                            }
                        ]
                    };
                    NSData *payload =
                        [NSJSONSerialization dataWithJSONObject:parameters options:0 error:nil];

                    return
                        [OHHTTPStubsResponse responseWithData:payload statusCode:200 headers:@{}];
                }];

            waitUntil(^(DoneCallback done) {
                operation.modifyRecordsCompletionBlock = ^(
                    NSArray<SKYRecordResult<SKYRecord *> *> *_Nullable results,
                    NSError *_Nullable operationError) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        expect(results).to.haveCountOf(2);

                        expect([(SKYRecord *)results[0].value recordID]).to.equal(record1.recordID);
                        expect([(SKYRecord *)results[1].value recordID]).to.equal(record2.recordID);
                        done();
                    });

                };
                [database executeOperation:operation];
            });
        });

        it(@"pass error", ^{
            SKYModifyRecordsOperation *operation =
                [SKYModifyRecordsOperation operationWithRecords:@[ record1, record2 ]];
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
                operation.modifyRecordsCompletionBlock =
                    ^(NSArray *savedRecords, NSError *operationError) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            expect(operationError).toNot.beNil();
                            done();
                        });
                    };
                [database executeOperation:operation];
            });
        });

        it(@"per block", ^{
            SKYModifyRecordsOperation *operation =
                [SKYModifyRecordsOperation operationWithRecords:@[ record1, record2 ]];

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
                                @"title" : @"Title From Server",
                            },
                            @{
                                @"_recordType" : @"book",
                                @"_recordID" : @"book2",
                                @"_type" : @"error",
                                @"code" : @(SKYErrorResourceNotFound),
                                @"message" : @"An error.",
                                @"name" : @"ResourceNotFound",
                            }
                        ]
                    };
                    NSData *payload =
                        [NSJSONSerialization dataWithJSONObject:parameters options:0 error:nil];

                    return
                        [OHHTTPStubsResponse responseWithData:payload statusCode:200 headers:@{}];
                }];

            waitUntil(^(DoneCallback done) {
                operation.modifyRecordsCompletionBlock = ^(
                    NSArray<SKYRecordResult<SKYRecord *> *> *_Nullable results,
                    NSError *_Nullable operationError) {
                    expect(results).to.haveCountOf(2);

                    expect([results[0].value class]).to.beSubclassOf([SKYRecord class]);
                    expect([(SKYRecord *)results[0].value recordID]).to.equal(record1.recordID);
                    expect(results[0].value[@"title"]).to.equal(@"Title From Server");

                    expect([results[1].error class]).to.beSubclassOf([NSError class]);
                    expect(results[1].error.userInfo[SKYErrorNameKey])
                        .to.equal(@"ResourceNotFound");
                    expect(results[1].error.code).to.equal(SKYErrorResourceNotFound);
                    expect(results[1].error.userInfo[SKYErrorMessageKey]).to.equal(@"An error.");
                    done();
                };

                [database executeOperation:operation];
            });
        });

        it(@"bug: server return write not allowed", ^{
            SKYModifyRecordsOperation *operation =
                [SKYModifyRecordsOperation operationWithRecords:@[ record1, record2 ]];
            [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
                return YES;
            }
                withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
                    NSDictionary *data = @{
                        @"result" : @{
                            @"code" : @201,
                            @"message" : @"invalid request: write is not allowed",
                        }
                    };
                    return [OHHTTPStubsResponse responseWithJSONObject:data
                                                            statusCode:401
                                                               headers:@{}];
                }];

            waitUntil(^(DoneCallback done) {
                operation.modifyRecordsCompletionBlock =
                    ^(NSArray *savedRecords, NSError *operationError) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            expect(operationError).toNot.beNil();
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
