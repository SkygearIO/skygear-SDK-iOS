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
    
    it(@"single record", ^{
        ODRecordID *recordID = [[ODRecordID alloc] initWithRecordName:@"book1"];
        ODDeleteRecordsOperation *operation = [[ODDeleteRecordsOperation alloc] initWithRecordIDsToDelete:@[recordID]];
        ODDatabase *database = [[ODContainer defaultContainer] publicCloudDatabase];
        operation.database = database;
        [operation prepareForRequest];
        ODRequest *request = operation.request;
        expect([request class]).to.beSubclassOf([ODRequest class]);
        expect(request.action).to.equal(@"record:delete");
        expect(request.payload[@"ids"]).to.equal(@[@"book1"]);
        expect(request.payload[@"database_id"]).to.equal(database.databaseID);
    });
    
    it(@"multiple record", ^{
        ODRecordID *recordID1 = [[ODRecordID alloc] initWithRecordName:@"book1"];
        ODRecordID *recordID2 = [[ODRecordID alloc] initWithRecordName:@"book2"];
        ODDeleteRecordsOperation *operation = [[ODDeleteRecordsOperation alloc] initWithRecordIDsToDelete:@[recordID1, recordID2]];
        ODDatabase *database = [[ODContainer defaultContainer] publicCloudDatabase];
        operation.database = database;
        [operation prepareForRequest];
        ODRequest *request = operation.request;
        expect([request class]).to.beSubclassOf([ODRequest class]);
        expect(request.action).to.equal(@"record:delete");
        expect(request.payload[@"ids"]).to.equal(@[@"book1", @"book2"]);
        expect(request.payload[@"database_id"]).to.equal(database.databaseID);
    });
    
    it(@"make request", ^{
        ODRecordID *recordID1 = [[ODRecordID alloc] initWithRecordName:@"book1"];
        ODRecordID *recordID2 = [[ODRecordID alloc] initWithRecordName:@"book2"];
        ODDeleteRecordsOperation *operation = [[ODDeleteRecordsOperation alloc] initWithRecordIDsToDelete:@[recordID1, recordID2]];
        ODDatabase *database = [[ODContainer defaultContainer] publicCloudDatabase];
        operation.database = database;
        
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
            
            [[[NSOperationQueue alloc] init] addOperation:operation];
        });
    });
    
    afterEach(^{
        [OHHTTPStubs removeAllStubs];
    });
});

SpecEnd
