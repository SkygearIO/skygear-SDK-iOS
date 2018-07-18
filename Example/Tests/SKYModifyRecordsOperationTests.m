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
                                       accessToken:[[SKYAccessToken alloc] initWithTokenString:@"ACCESS_TOKEN"]];
            database = [container publicCloudDatabase];
            record1 = [[SKYRecord alloc] initWithRecordID:[[SKYRecordID alloc] initWithRecordType:@"book" name:@"book1"]
                                                     data:nil];
            record2 = [[SKYRecord alloc] initWithRecordID:[[SKYRecordID alloc] initWithRecordType:@"book" name:@"book2"]
                                                     data:nil];
        });

        it(@"multiple record", ^{
            SKYModifyRecordsOperation *operation =
                [SKYModifyRecordsOperation operationWithRecordsToSave:@[ record1, record2 ]];
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
                [SKYModifyRecordsOperation operationWithRecordsToSave:@[ record1, record2 ]];
            operation.atomic = YES;

            operation.container = container;
            operation.database = database;
            [operation makeURLRequestWithError:nil];

            SKYRequest *request = operation.request;
            expect(request.payload[@"atomic"]).to.equal(@YES);
        });

        it(@"make request", ^{
            SKYModifyRecordsOperation *operation =
                [SKYModifyRecordsOperation operationWithRecordsToSave:@[ record1, record2 ]];

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
                                @"_revision" : @"revision1",
                            },
                            @{
                                @"_id" : @"book/book2",
                                @"_type" : @"record",
                                @"_revision" : @"revision2",
                            }
                        ]
                    };
                    NSData *payload = [NSJSONSerialization dataWithJSONObject:parameters options:0 error:nil];

                    return [OHHTTPStubsResponse responseWithData:payload statusCode:200 headers:@{}];
                }];

            waitUntil(^(DoneCallback done) {
                operation.modifyRecordsCompletionBlock = ^(NSArray *savedRecords, NSError *operationError) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        expect([savedRecords class]).to.beSubclassOf([NSArray class]);
                        expect(savedRecords).to.haveCountOf(2);
                        expect([savedRecords[0] recordID]).to.equal(record1.recordID);
                        expect([savedRecords[1] recordID]).to.equal(record2.recordID);
                        done();
                    });
                };

                [database executeOperation:operation];
            });
        });

        it(@"pass error", ^{
            SKYModifyRecordsOperation *operation =
                [SKYModifyRecordsOperation operationWithRecordsToSave:@[ record1, record2 ]];
            [OHHTTPStubs
                stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
                    return YES;
                }
                withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
                    return [OHHTTPStubsResponse
                        responseWithError:[NSError errorWithDomain:NSURLErrorDomain code:0 userInfo:nil]];
                }];

            waitUntil(^(DoneCallback done) {
                operation.modifyRecordsCompletionBlock = ^(NSArray *savedRecords, NSError *operationError) {
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
                [SKYModifyRecordsOperation operationWithRecordsToSave:@[ record1, record2 ]];

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
                                @"_revision" : @"revision1",
                                @"title" : @"Title From Server",
                            },
                            @{
                                @"_id" : @"book/book2",
                                @"_type" : @"error",
                                @"code" : @(SKYErrorResourceNotFound),
                                @"message" : @"An error.",
                                @"name" : @"ResourceNotFound",
                            }
                        ]
                    };
                    NSData *payload = [NSJSONSerialization dataWithJSONObject:parameters options:0 error:nil];

                    return [OHHTTPStubsResponse responseWithData:payload statusCode:200 headers:@{}];
                }];

            waitUntil(^(DoneCallback done) {
                NSMutableArray *remainingRecordIDs = [@[ record1.recordID, record2.recordID ] mutableCopy];

                operation.perRecordCompletionBlock = ^(SKYRecord *record, NSError *error) {
                    if ([record.recordID isEqual:record1.recordID]) {
                        expect([record class]).to.beSubclassOf([SKYRecord class]);
                        expect(record.recordID).to.equal(record1.recordID);
                        expect(record[@"title"]).to.equal(@"Title From Server");
                    } else if ([record.recordID isEqual:record2.recordID]) {
                        expect([error class]).to.beSubclassOf([NSError class]);
                        expect(error.userInfo[SKYErrorNameKey]).to.equal(@"ResourceNotFound");
                        expect(error.code).to.equal(SKYErrorResourceNotFound);
                        expect(error.userInfo[SKYErrorMessageKey]).to.equal(@"An error.");
                    }
                    [remainingRecordIDs removeObject:record.recordID];
                };

                operation.modifyRecordsCompletionBlock = ^(NSArray *savedRecords, NSError *operationError) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        expect(savedRecords).to.haveCountOf(1);
                        expect(remainingRecordIDs).to.haveCountOf(0);
                        expect([operationError class]).to.beSubclassOf([NSError class]);
                        expect(operationError.code).to.equal(SKYErrorPartialFailure);

                        NSError *perRecordError =
                            operationError.userInfo[SKYPartialErrorsByItemIDKey][record2.recordID];
                        expect([perRecordError class]).to.beSubclassOf([NSError class]);
                        expect(perRecordError.userInfo[SKYErrorNameKey]).to.equal(@"ResourceNotFound");
                        expect(perRecordError.code).to.equal(SKYErrorResourceNotFound);
                        expect(perRecordError.userInfo[SKYErrorMessageKey]).to.equal(@"An error.");
                        done();
                    });
                };

                [database executeOperation:operation];
            });
        });

        it(@"bug: server return write not allowed", ^{
            SKYModifyRecordsOperation *operation =
                [SKYModifyRecordsOperation operationWithRecordsToSave:@[ record1, record2 ]];
            [OHHTTPStubs
                stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
                    return YES;
                }
                withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
                    NSDictionary *data = @{
                        @"result" : @{
                            @"code" : @201,
                            @"message" : @"invalid request: write is not allowed",
                        }
                    };
                    return [OHHTTPStubsResponse responseWithJSONObject:data statusCode:401 headers:@{}];
                }];

            waitUntil(^(DoneCallback done) {
                operation.modifyRecordsCompletionBlock = ^(NSArray *savedRecords, NSError *operationError) {
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
