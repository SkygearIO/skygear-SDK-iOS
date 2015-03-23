//
//  ODModifyRecordsOperationTests.m
//  ODKit
//
//  Created by Patrick Cheung on 27/2/15.
//  Copyright (c) 2015 Kwok-kuen Cheung. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ODKit/ODKit.h>
#import <OHHTTPStubs/OHHTTPStubs.h>

SpecBegin(ODModifyRecordsOperation)

describe(@"modify", ^{
    __block ODRecord *record1 = nil;
    __block ODRecord *record2 = nil;
    __block ODContainer *container = nil;
    __block ODDatabase *database = nil;
    
    beforeEach(^{
        container = [[ODContainer alloc] init];
        [container updateWithUserRecordID:[[ODUserRecordID alloc] initWithRecordType:@"user" name:@"USER_ID"]
                              accessToken:[[ODAccessToken alloc] initWithTokenString:@"ACCESS_TOKEN"]];
        database = [container publicCloudDatabase];
        record1 = [[ODRecord alloc] initWithRecordType:@"book"
                                              recordID:[[ODRecordID alloc] initWithRecordType:@"book" name:@"book1"]];
        record2 = [[ODRecord alloc] initWithRecordType:@"book"
                                              recordID:[[ODRecordID alloc] initWithRecordType:@"book" name:@"book2"]];
    });
    
    it(@"multiple record", ^{
        ODModifyRecordsOperation *operation = [[ODModifyRecordsOperation alloc] initWithRecordsToSave:@[record1, record2]];
        operation.container = container;
        operation.database = database;
        [operation prepareForRequest];
        ODRequest *request = operation.request;
        expect([request class]).to.beSubclassOf([ODRequest class]);
        expect(request.action).to.equal(@"record:save");
        expect(request.payload[@"records"]).to.haveCountOf(2);
        expect(request.accessToken).to.equal(container.currentAccessToken);
        
        NSDictionary *recordPayload = request.payload[@"records"][0];
        expect(recordPayload[ODRecordSerializationRecordIDKey]).to.equal(@"book1");
        recordPayload = request.payload[@"records"][1];
        expect(recordPayload[ODRecordSerializationRecordIDKey]).to.equal(@"book2");
        expect(request.payload[@"database_id"]).to.equal(database.databaseID);
    });
    
    it(@"make request", ^{
        ODModifyRecordsOperation *operation = [[ODModifyRecordsOperation alloc] initWithRecordsToSave:@[record1, record2]];
        
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
                                                     @"_revision": @"revision1",
                                                     },
                                                 @{
                                                     @"_id": @"book2",
                                                     @"_type": @"book",
                                                     @"_revision": @"revision2",
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
        ODModifyRecordsOperation *operation = [[ODModifyRecordsOperation alloc] initWithRecordsToSave:@[record1, record2]];
        [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
            return YES;
        } withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
            return [OHHTTPStubsResponse responseWithError:[NSError errorWithDomain:NSURLErrorDomain code:0 userInfo:nil]];
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
