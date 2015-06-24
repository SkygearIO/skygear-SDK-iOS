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
        [container updateWithUserRecordID:[ODUserRecordID recordIDWithUsername:@"USER_ID"]
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
        expect(request.payload[@"predicate"]).to.equal(nil);
    });
    
    it(@"simple query", ^{
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name = %@", @"A tale of two cities"];
        ODQuery *query = [[ODQuery alloc] initWithRecordType:@"book"
                                                   predicate:predicate];
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
        
        NSArray *predicateArray = request.payload[@"predicate"];
        expect([predicateArray class]).to.beSubclassOf([NSArray class]);
        expect(predicateArray[0]).to.equal(@"eq");
        expect(predicateArray[1]).to.equal(@{@"$type": @"keypath", @"$val": @"name"});
        expect(predicateArray[2]).to.equal(@"A tale of two cities");
    });
    
    it(@"sorted", ^{
        ODQuery *query = [[ODQuery alloc] initWithRecordType:@"book" predicate:nil];
        query.sortDescriptors = @[
                                  [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]];
        ODQueryOperation *operation = [[ODQueryOperation alloc] initWithQuery:query];
        ODDatabase *database = [[ODContainer defaultContainer] publicCloudDatabase];
        operation.container = container;
        operation.database = database;
        [operation prepareForRequest];
        ODRequest *request = operation.request;
        
        expect(request.payload[@"sort"][0]).to.equal(@[@{@"$type": @"keypath", @"$val": @"name"}, @"asc"]);
    });
    
    it(@"eager", ^{
        ODQuery *query = [[ODQuery alloc] initWithRecordType:@"book" predicate:nil];
        query.eagerLoadKeyPath = @"shelf";
        ODQueryOperation *operation = [[ODQueryOperation alloc] initWithQuery:query];
        ODDatabase *database = [[ODContainer defaultContainer] publicCloudDatabase];
        operation.container = container;
        operation.database = database;
        [operation prepareForRequest];
        ODRequest *request = operation.request;
        
        expect(request.payload[@"eager"][0]).to.equal(@{@"$type": @"keypath", @"$val": @"shelf"});
    });
    
    it(@"eager", ^{
        ODQuery *query = [[ODQuery alloc] initWithRecordType:@"note" predicate:nil];
        query.eagerLoadKeyPath = @"category";
        ODQueryOperation *operation = [[ODQueryOperation alloc] initWithQuery:query];
        ODDatabase *database = [[ODContainer defaultContainer] publicCloudDatabase];
        operation.container = container;
        operation.database = database;
        [operation prepareForRequest];
        ODRequest *request = operation.request;
        
        expect(request.payload[@"eager"][0]).to.equal(@{@"$type": @"keypath", @"$val": @"category"});
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

    it(@"per block", ^{
        ODRecordID *recordID1 = [[ODRecordID alloc] initWithRecordType:@"book" name:@"book1"];
        ODQuery *query = [[ODQuery alloc] initWithRecordType:@"book" predicate:nil];
        ODQueryOperation *operation = [[ODQueryOperation alloc] initWithQuery:query];
        
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
            NSMutableArray *remainingRecordIDs = [@[recordID1] mutableCopy];
            operation.perRecordCompletionBlock = ^(ODRecord *record) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    expect(record).toNot.beNil();
                    ODRecordID *recordID = record.recordID;
                    if ([recordID isEqual:recordID1]) {
                        expect([record class]).to.beSubclassOf([ODRecord class]);
                        expect(record.recordID).to.equal(recordID1);
                    }
                    [remainingRecordIDs removeObject:recordID];
                });
            };
            
            operation.queryRecordsCompletionBlock = ^(NSArray *fetchedRecords, ODQueryCursor *cursor, NSError *operationError) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    expect(remainingRecordIDs).to.haveCountOf(0);
                    done();
                });
            };
            
            
            [database executeOperation:operation];
        });
    });
    
    it(@"per block with eager load", ^{
        ODRecordID *recordID1 = [[ODRecordID alloc] initWithRecordType:@"book" name:@"book1"];
        ODQuery *query = [[ODQuery alloc] initWithRecordType:@"book" predicate:nil];
        query.eagerLoadKeyPath = @"category";
        ODQueryOperation *operation = [[ODQueryOperation alloc] initWithQuery:query];
        
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
                                                     @"category": @{@"$type": @"ref", @"$id": @"category/important"}
                                                     },
                                                 ],
                                         @"other_result": @{
                                                 @"eager_load": @[
                                                         @{
                                                             @"_id": @"category/important",
                                                             @"_type": @"record",
                                                             @"title": @"Important",
                                                             }
                                                         ]
                                                 }
                                         };
            NSData *payload = [NSJSONSerialization dataWithJSONObject:parameters
                                                              options:0
                                                                error:nil];
            
            return [OHHTTPStubsResponse responseWithData:payload
                                              statusCode:200
                                                 headers:@{}];
        }];
        
        waitUntil(^(DoneCallback done) {
            NSMutableArray *remainingRecordIDs = [@[recordID1] mutableCopy];
            operation.perRecordCompletionWithEagerLoadBlock = ^(ODRecord *record, NSArray *eagerLoadedRecords) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    expect(eagerLoadedRecords).to.haveCountOf(1);
                    expect(eagerLoadedRecords[0][@"title"]).to.equal(@"Important");
                    
                    expect(record).toNot.beNil();
                    ODRecordID *recordID = record.recordID;
                    if ([recordID isEqual:recordID1]) {
                        expect([record class]).to.beSubclassOf([ODRecord class]);
                        expect(record.recordID).to.equal(recordID1);
                    }
                    [remainingRecordIDs removeObject:recordID];
                });
            };
           
            operation.queryRecordsCompletionBlock = ^(NSArray *fetchedRecords, ODQueryCursor *cursor, NSError *operationError) {
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
