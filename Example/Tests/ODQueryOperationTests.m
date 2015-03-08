//
//  ODQueryOperationTests.m
//  ODKit
//
//  Created by Patrick Cheung on 2/3/15.
//  Copyright (c) 2015 Kwok-kuen Cheung. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ODKit/ODKit.h>
#import <OHHTTPStubs/OHHTTPStubs.h>

SpecBegin(ODQueryOperation)

describe(@"fetch", ^{
    __block ODContainer *container = nil;
    __block ODDatabase *database = nil;

    beforeEach(^{
        container = [[ODContainer alloc] init];
        [container updateWithUserRecordID:[[ODUserRecordID alloc] initWithRecordName:@"USER_ID"]
                              accessToken:[[ODAccessToken alloc] initWithTokenString:@"ACCESS_TOKEN"]];
        database = [container publicCloudDatabase];
    });
    
    it(@"empty predicate", ^{
        ODQuery *query = [[ODQuery alloc] initWithRecordType:@"book" predicate:nil];
        ODQueryOperation *operation = [[ODQueryOperation alloc] initWithQuery:query];
        ODDatabase *database = [[ODContainer defaultContainer] publicCloudDatabase];
        operation.container = container;
        operation.database = database;
        [operation prepareForRequest];
        ODRequest *request = operation.request;
        expect([request class]).to.beSubclassOf([ODRequest class]);
        expect(request.action).to.equal(@"record:query");
        expect(request.accessToken).to.equal(container.currentAccessToken);
        expect(request.payload[@"record_type"]).to.equal(@"book");
        expect(request.payload[@"database_id"]).to.equal(database.databaseID);
    });
    
    it(@"make request", ^{
        ODQuery *query = [[ODQuery alloc] initWithRecordType:@"book" predicate:nil];
        ODQueryOperation *operation = [[ODQueryOperation alloc] initWithQuery:query];
        ODDatabase *database = [[ODContainer defaultContainer] publicCloudDatabase];
        operation.database = database;
        
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
            operation.queryRecordsCompletionBlock = ^(NSArray *fetchedRecords, ODQueryCursor *cursor, NSError *operationError) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    expect([fetchedRecords class]).to.beSubclassOf([NSArray class]);
                    expect(fetchedRecords).to.haveCountOf(2);
                    expect([[fetchedRecords[0] recordID] recordName]).to.equal(@"book1");
                    expect([[fetchedRecords[1] recordID] recordName]).to.equal(@"book2");
                    done();
                });
            };
            
            [container addOperation:operation];
        });
    });
    
    it(@"pass error", ^{
        ODQuery *query = [[ODQuery alloc] initWithRecordType:@"book" predicate:nil];
        ODQueryOperation *operation = [[ODQueryOperation alloc] initWithQuery:query];
        [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
            return YES;
        } withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
            return [OHHTTPStubsResponse responseWithError:[NSError errorWithDomain:NSURLErrorDomain code:0 userInfo:nil]];
        }];
        
        waitUntil(^(DoneCallback done) {
            operation.queryRecordsCompletionBlock = ^(NSArray *fetchedRecords, ODQueryCursor *cursor, NSError *operationError) {
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
