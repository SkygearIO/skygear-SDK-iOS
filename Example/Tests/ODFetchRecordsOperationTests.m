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
        [container updateWithUserRecordID:[[ODUserRecordID alloc] initWithRecordName:@"USER_ID"]
                              accessToken:[[ODAccessToken alloc] initWithTokenString:@"ACCESS_TOKEN"]];
        database = [container publicCloudDatabase];
    });
        
    it(@"single record", ^{
        ODRecordID *recordID = [[ODRecordID alloc] initWithRecordName:@"book1"];
        ODFetchRecordsOperation *operation = [[ODFetchRecordsOperation alloc] initWithRecordIDs:@[recordID]];
        operation.container = container;
        operation.database = database;
        [operation prepareForRequest];
        ODRequest *request = operation.request;
        expect([request class]).to.beSubclassOf([ODRequest class]);
        expect(request.action).to.equal(@"record:fetch");
        expect(request.accessToken).to.equal(container.currentAccessToken);
        expect(request.payload[@"ids"]).to.equal(@[@"book1"]);
        expect(request.payload[@"database_id"]).to.equal(database.databaseID);
        expect(request.payload).toNot.contain(@"desired_keys");
    });
    
    it(@"multiple record", ^{
        ODRecordID *recordID1 = [[ODRecordID alloc] initWithRecordName:@"book1"];
        ODRecordID *recordID2 = [[ODRecordID alloc] initWithRecordName:@"book2"];
        ODFetchRecordsOperation *operation = [[ODFetchRecordsOperation alloc] initWithRecordIDs:@[recordID1, recordID2]];
        operation.container = container;
        operation.database = database;
        [operation prepareForRequest];
        ODRequest *request = operation.request;
        expect([request class]).to.beSubclassOf([ODRequest class]);
        expect(request.action).to.equal(@"record:fetch");
        expect(request.accessToken).to.equal(container.currentAccessToken);
        expect(request.payload[@"ids"]).to.equal(@[@"book1", @"book2"]);
        expect(request.payload[@"database_id"]).to.equal(database.databaseID);
        expect(request.payload).toNot.contain(@"desired_keys");
    });
    
    it(@"make request", ^{
        ODRecordID *recordID1 = [[ODRecordID alloc] initWithRecordName:@"book1"];
        ODRecordID *recordID2 = [[ODRecordID alloc] initWithRecordName:@"book2"];
        ODFetchRecordsOperation *operation = [[ODFetchRecordsOperation alloc] initWithRecordIDs:@[recordID1, recordID2]];

        [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
            return YES;
        } withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
            NSDictionary *parameters = @{
                                         @"request_id": @"REQUEST_ID",
                                         @"database_id": database.databaseID,
                                         @"result": @[
                                                 @{
                                                     @"_id": @"book1",
                                                     @"_type": @"book",
                                                     @"title": @"A tale of two cities",
                                                     },
                                                 @{
                                                     @"_id": @"book2",
                                                     @"_type": @"book",
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
        ODRecordID *recordID1 = [[ODRecordID alloc] initWithRecordName:@"book1"];
        ODRecordID *recordID2 = [[ODRecordID alloc] initWithRecordName:@"book2"];
        ODFetchRecordsOperation *operation = [[ODFetchRecordsOperation alloc] initWithRecordIDs:@[recordID1, recordID2]];
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

    afterEach(^{
        [OHHTTPStubs removeAllStubs];
    });
});

SpecEnd
