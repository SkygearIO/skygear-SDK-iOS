//
//  ODFetchRecordsOperationTests.m
//  ODKit
//
//  Created by Patrick Cheung on 26/2/15.
//  Copyright (c) 2015 Kwok-kuen Cheung. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ODKit/ODKit.h>
#import <OHHTTPStubs/OHHTTPStubs.h>

SpecBegin(ODFetchRecordsOperation)

describe(@"fetch", ^{
    __block ODContainer *container = nil;
    __block ODDatabase *database = nil;
    
    beforeEach(^{
        container = [[ODContainer alloc] init];
        [container updateWithUserRecordID:[ODUserRecordID recordIDWithUsername:@"USER_ID"]
                              accessToken:[[ODAccessToken alloc] initWithTokenString:@"ACCESS_TOKEN"]];
        database = [container publicCloudDatabase];
    });
    
    it(@"single record", ^{
        ODRecordID *recordID = [[ODRecordID alloc] initWithRecordType:@"book" name:@"book1"];
        ODFetchRecordsOperation *operation = [ODFetchRecordsOperation operationWithRecordIDs:@[recordID]];
        operation.container = container;
        operation.database = database;
        [operation prepareForRequest];
        ODRequest *request = operation.request;
        expect([request class]).to.beSubclassOf([ODRequest class]);
        expect(request.action).to.equal(@"record:fetch");
        expect(request.accessToken).to.equal(container.currentAccessToken);
        expect(request.payload[@"ids"]).to.equal(@[recordID.canonicalString]);
        expect(request.payload[@"database_id"]).to.equal(database.databaseID);
        expect(request.payload).toNot.contain(@"desired_keys");
    });
    
    it(@"multiple record", ^{
        ODRecordID *recordID1 = [[ODRecordID alloc] initWithRecordType:@"book" name:@"book1"];
        ODRecordID *recordID2 = [[ODRecordID alloc] initWithRecordType:@"book" name:@"book2"];
        ODFetchRecordsOperation *operation = [ODFetchRecordsOperation operationWithRecordIDs:@[recordID1, recordID2]];
        operation.container = container;
        operation.database = database;
        [operation prepareForRequest];
        ODRequest *request = operation.request;
        expect([request class]).to.beSubclassOf([ODRequest class]);
        expect(request.action).to.equal(@"record:fetch");
        expect(request.accessToken).to.equal(container.currentAccessToken);
        expect(request.payload[@"ids"]).to.equal(@[recordID1.canonicalString, recordID2.canonicalString]);
        expect(request.payload[@"database_id"]).to.equal(database.databaseID);
        expect(request.payload).toNot.contain(@"desired_keys");
    });
    
    it(@"make request", ^{
        ODRecordID *recordID1 = [[ODRecordID alloc] initWithRecordType:@"book" name:@"book1"];
        ODRecordID *recordID2 = [[ODRecordID alloc] initWithRecordType:@"book" name:@"book2"];
        ODFetchRecordsOperation *operation = [ODFetchRecordsOperation operationWithRecordIDs:@[recordID1, recordID2]];
        
        [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
            return YES;
        } withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
            NSDictionary *parameters = @{
                                         @"request_id": @"REQUEST_ID",
                                         @"database_id": database.databaseID,
                                         @"result": @[
                                                 @{
                                                     @"_id": @"book/book1",
                                                     @"_type": @"record",
                                                     @"title": @"A tale of two cities",
                                                     },
                                                 @{
                                                     @"_id": @"book/book2",
                                                     @"_type": @"record",
                                                     @"title": @"Old man and the sea",
                                                     }
                                                 ]
                                         };
            NSData *payload = [NSJSONSerialization dataWithJSONObject:parameters
                                                              options:0
                                                                error:nil];
            
            return [OHHTTPStubsResponse responseWithData:payload
                                              statusCode:200
                                                 headers:@{}];
        }];
        
        waitUntil(^(DoneCallback done) {
            operation.fetchRecordsCompletionBlock = ^(NSDictionary *recordsByRecordID, NSError *operationError) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    expect([recordsByRecordID class]).to.beSubclassOf([NSDictionary class]);
                    expect(recordsByRecordID).to.haveCountOf(2);
                    expect([recordsByRecordID[recordID1] recordID]).to.equal(recordID1);
                    expect([recordsByRecordID[recordID2] recordID]).to.equal(recordID2);
                    done();
                });
            };
            
            [database executeOperation:operation];
        });
    });
    
    it(@"pass error", ^{
        ODRecordID *recordID1 = [[ODRecordID alloc] initWithRecordType:@"book" name:@"book1"];
        ODRecordID *recordID2 = [[ODRecordID alloc] initWithRecordType:@"book" name:@"book2"];
        ODFetchRecordsOperation *operation = [ODFetchRecordsOperation operationWithRecordIDs:@[recordID1, recordID2]];
        [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
            return YES;
        } withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
            return [OHHTTPStubsResponse responseWithError:[NSError errorWithDomain:NSURLErrorDomain code:0 userInfo:nil]];
        }];
        
        waitUntil(^(DoneCallback done) {
            operation.fetchRecordsCompletionBlock = ^(NSDictionary *recordsByRecordID, NSError *operationError) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    expect(operationError).toNot.beNil();
                    done();
                });
            };
            [database executeOperation:operation];
        });
    });
    
    it(@"per block", ^{
        ODRecordID *recordID1 = [[ODRecordID alloc] initWithRecordType:@"book" name:@"book1"];
        ODRecordID *recordID2 = [[ODRecordID alloc] initWithRecordType:@"book" name:@"book2"];
        ODRecordID *recordID3 = [[ODRecordID alloc] initWithRecordType:@"book" name:@"book3"];
        ODFetchRecordsOperation *operation = [ODFetchRecordsOperation operationWithRecordIDs:@[recordID1, recordID2]];
        
        [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
            return YES;
        } withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
            NSDictionary *parameters = @{
                                         @"request_id": @"REQUEST_ID",
                                         @"database_id": database.databaseID,
                                         @"result": @[
                                                 @{
                                                     @"_id": @"book/book1",
                                                     @"_type": @"record",
                                                     @"title": @"A tale of two cities",
                                                     },
                                                 @{
                                                     @"_id": @"book/book2",
                                                     @"_type": @"error",
                                                     @"code": @(100),
                                                     @"message": @"An error.",
                                                     @"type": @"FetchError",
                                                     },
                                                 @{
                                                     @"_id": @"book/book3",
                                                     @"_type": @"unknown",
                                                     },
                                                 ]
                                         };
            NSData *payload = [NSJSONSerialization dataWithJSONObject:parameters
                                                              options:0
                                                                error:nil];
            
            return [OHHTTPStubsResponse responseWithData:payload
                                              statusCode:200
                                                 headers:@{}];
        }];
        
        waitUntil(^(DoneCallback done) {
            NSMutableArray *remainingRecordIDs = [@[recordID1, recordID2, recordID3] mutableCopy];
            operation.perRecordCompletionBlock = ^(ODRecord *record, ODRecordID *recordID, NSError *error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if ([recordID isEqual:recordID1]) {
                        expect([record class]).to.beSubclassOf([ODRecord class]);
                        expect(record.recordID).to.equal(recordID1);
                    } else if ([recordID isEqual:recordID2]) {
                        expect([error class]).to.beSubclassOf([NSError class]);
                        expect([error ODErrorType]).to.equal(@"FetchError");
                    } else if ([recordID isEqual:recordID3]) {
                        expect([error class]).to.beSubclassOf([NSError class]);
                    }
                    [remainingRecordIDs removeObject:recordID];
                });
            };
            
            operation.fetchRecordsCompletionBlock = ^(NSDictionary *recordsByRecordID, NSError *operationError) {
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
