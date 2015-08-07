//
//  ODDeleteRecordsOperationTests.m
//  ODKit
//
//  Created by Patrick Cheung on 1/3/15.
//  Copyright (c) 2015 Kwok-kuen Cheung. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ODKit/ODKit.h>
#import <OHHTTPStubs/OHHTTPStubs.h>

SpecBegin(ODDeleteRecordsOperation)

describe(@"delete", ^{
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
        ODDeleteRecordsOperation *operation = [ODDeleteRecordsOperation operationWithRecordIDsToDelete:@[recordID]];
        operation.database = database;
        operation.container = container;
        [operation prepareForRequest];
        ODRequest *request = operation.request;
        expect([request class]).to.beSubclassOf([ODRequest class]);
        expect(request.action).to.equal(@"record:delete");
        expect(request.accessToken).to.equal(container.currentAccessToken);
        expect(request.payload[@"ids"]).to.equal(@[recordID.canonicalString]);
        expect(request.payload[@"database_id"]).to.equal(database.databaseID);
    });
    
    it(@"multiple record", ^{
        ODRecordID *recordID1 = [[ODRecordID alloc] initWithRecordType:@"book" name:@"book1"];
        ODRecordID *recordID2 = [[ODRecordID alloc] initWithRecordType:@"book" name:@"book2"];
        ODDeleteRecordsOperation *operation = [ODDeleteRecordsOperation operationWithRecordIDsToDelete:@[recordID1, recordID2]];
        operation.database = database;
        operation.container = container;
        [operation prepareForRequest];
        ODRequest *request = operation.request;
        expect([request class]).to.beSubclassOf([ODRequest class]);
        expect(request.action).to.equal(@"record:delete");
        expect(request.accessToken).to.equal(container.currentAccessToken);
        expect(request.payload[@"ids"]).to.equal(@[recordID1.canonicalString, recordID2.canonicalString]);
        expect(request.payload[@"database_id"]).to.equal(database.databaseID);
    });

    it(@"set atomic", ^{
        ODDeleteRecordsOperation *operation = [ODDeleteRecordsOperation operationWithRecordIDsToDelete:@[]];
        operation.atomic = YES;

        operation.database = database;
        operation.container = container;
        [operation prepareForRequest];

        ODRequest *request = operation.request;
        expect(request.payload[@"atomic"]).to.equal(@YES);
    });

    it(@"make request", ^{
        ODRecordID *recordID1 = [[ODRecordID alloc] initWithRecordType:@"book" name:@"book1"];
        ODRecordID *recordID2 = [[ODRecordID alloc] initWithRecordType:@"book" name:@"book2"];
        ODDeleteRecordsOperation *operation = [ODDeleteRecordsOperation operationWithRecordIDsToDelete:@[recordID1, recordID2]];
        
        [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
            return YES;
        } withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
            NSDictionary *parameters = @{
                                         @"request_id": @"REQUEST_ID",
                                         @"database_id": database.databaseID,
                                         @"result": @[]
                                         };
            NSData *payload = [NSJSONSerialization dataWithJSONObject:parameters
                                                              options:0
                                                                error:nil];
            
            return [OHHTTPStubsResponse responseWithData:payload
                                              statusCode:200
                                                 headers:@{}];
        }];
        
        waitUntil(^(DoneCallback done) {
            operation.deleteRecordsCompletionBlock = ^(NSArray *recordIDs, NSError *operationError) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    expect([recordIDs class]).to.beSubclassOf([NSArray class]);
                    expect(recordIDs).to.haveCountOf(2);
                    expect(recordIDs).to.contain(recordID1);
                    expect(recordIDs).to.contain(recordID2);
                    done();
                });
            };
            
            [database executeOperation:operation];
        });
    });
    
    it(@"pass error", ^{
        ODRecordID *recordID1 = [[ODRecordID alloc] initWithRecordType:@"book" name:@"book1"];
        ODRecordID *recordID2 = [[ODRecordID alloc] initWithRecordType:@"book" name:@"book2"];
        ODDeleteRecordsOperation *operation = [ODDeleteRecordsOperation operationWithRecordIDsToDelete:@[recordID1, recordID2]];
        [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
            return YES;
        } withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
            return [OHHTTPStubsResponse responseWithError:[NSError errorWithDomain:NSURLErrorDomain code:0 userInfo:nil]];
        }];
        
        waitUntil(^(DoneCallback done) {
            operation.deleteRecordsCompletionBlock = ^(NSArray *recordIDs, NSError *operationError) {
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
        ODDeleteRecordsOperation *operation = [ODDeleteRecordsOperation operationWithRecordIDsToDelete:@[recordID1, recordID2]];
        
        [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
            return YES;
        } withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
            NSDictionary *parameters = @{
                                         @"request_id": @"REQUEST_ID",
                                         @"database_id": database.databaseID,
                                         @"result": @[
                                                 @{
                                                     @"_id": @"book/book2",
                                                     @"_type": @"error",
                                                     @"code": @(100),
                                                     @"message": @"An error.",
                                                     @"type": @"Error",
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
            NSMutableArray *remaingRecordIDs = [@[recordID1, recordID2] mutableCopy];
            operation.perRecordCompletionBlock = ^(ODRecordID *recordID, NSError *error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [remaingRecordIDs removeObject:recordID];
                });
            };
            
            operation.deleteRecordsCompletionBlock = ^(NSArray *recordIDs, NSError *operationError) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    expect(recordIDs).to.haveCountOf(1);
                    expect(remaingRecordIDs).to.haveCountOf(0);
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
