//
//  ODDatabaseTest.m
//  ODKit
//
//  Created by Patrick Cheung on 27/2/15.
//  Copyright (c) 2015 Kwok-kuen Cheung. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ODKit/ODKit.h>
#import <OHHTTPStubs/OHHTTPStubs.h>

SpecBegin(ODDatabase)

describe(@"database", ^{
    it(@"fetch record", ^{
        ODDatabase *database = [[ODContainer defaultContainer] publicCloudDatabase];
        NSString *bookTitle = @"A tale of two cities";
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
                                                     @"title": bookTitle,
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
            [database fetchRecordWithID:[[ODRecordID alloc] initWithRecordName:@"book1"]
                      completionHandler:^(ODRecord *record, NSError *error) {
                          dispatch_async(dispatch_get_main_queue(), ^{
                              expect(record.recordID.recordName).to.equal(@"book1");
                              expect(record[@"title"]).to.equal(bookTitle);
                              done();
                          });
                      }];
        });
        
    });
    
    it(@"modify record", ^{
        ODDatabase *database = [[ODContainer defaultContainer] publicCloudDatabase];
        NSString *bookTitle = @"A tale of two cities";
        ODRecord *record = [[ODRecord alloc] initWithRecordType:@"book"
                                                       recordID:[[ODRecordID alloc] initWithRecordName:@"book1"]];
        record[@"title"] = bookTitle;
        
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
            [database saveRecord:record
                      completion:^(ODRecord *record, NSError *error) {
                          dispatch_async(dispatch_get_main_queue(), ^{
                              expect(record.recordID.recordName).to.equal(@"book1");
                              done();
                          });
                      }];
        });
        
    });
    
    it(@"delete record", ^{
        ODDatabase *database = [[ODContainer defaultContainer] publicCloudDatabase];
        ODRecordID *recordID = [[ODRecordID alloc] initWithRecordName:@"book1"];
        
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
            [database deleteRecordWithID:recordID
                       completionHandler:^(ODRecordID *recordID, NSError *error) {
                           dispatch_async(dispatch_get_main_queue(), ^{
                               expect(recordID.recordName).to.equal(@"book1");
                               done();
                           });
                       }];
        });
        
    });
});

SpecEnd