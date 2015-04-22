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
                                                     @"_id": @"book/book1",
                                                     @"_type": @"record",
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
            [database fetchRecordWithID:[[ODRecordID alloc] initWithRecordType:@"book" name:@"book1"]
                      completionHandler:^(ODRecord *record, NSError *error) {
                          dispatch_async(dispatch_get_main_queue(), ^{
                              expect(record.recordID.recordName).to.equal(@"book1");
                              expect(record.recordID.recordType).to.equal(@"book");
                              expect(record[@"title"]).to.equal(bookTitle);
                              done();
                          });
                      }];
        });
        
    });
    
    it(@"fetch records", ^{
        ODDatabase *database = [[ODContainer defaultContainer] publicCloudDatabase];
        ODRecordID *recordID1 = [[ODRecordID alloc] initWithRecordType:@"book" name:@"book1"];
        ODRecordID *recordID2 = [[ODRecordID alloc] initWithRecordType:@"book" name:@"book2"];
        NSString *bookTitle = @"A tale of two cities";
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
                                                     @"title": bookTitle,
                                                     },
                                                 @{
                                                     @"_id": @"book/book2",
                                                     @"_type": @"error",
                                                     @"code": @(100),
                                                     @"message": @"An error.",
                                                     @"type": @"SaveError",
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
            __block NSUInteger errorHandlerCallCount = 0;
                        
            [database fetchRecordsWithIDs:@[recordID1, recordID2]
                        completionHandler:^(NSDictionary *recordsByRecordID, NSError *operationError) {
                            expect(recordsByRecordID).to.contain(recordID1);
                            expect(recordsByRecordID).to.haveCountOf(1);
                            
                            if (errorHandlerCallCount == 1) {
                                done();
                            }
                        }
                    perRecordErrorHandler:^(ODRecordID *recordID, NSError *error) {
                        expect(recordID).to.equal(recordID2);
                        errorHandlerCallCount++;
                    }];
        });
        
    });
    
    it(@"modify record", ^{
        ODDatabase *database = [[ODContainer defaultContainer] publicCloudDatabase];
        NSString *bookTitle = @"A tale of two cities";
        ODRecord *record = [[ODRecord alloc] initWithRecordID:[[ODRecordID alloc] initWithRecordType:@"book" name:@"book1"] data:nil];
        record[@"title"] = bookTitle;
        
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
                              expect(record.recordID.recordType).to.equal(@"book");
                              done();
                          });
                      }];
        });
        
    });
    
    it(@"modify records", ^{
        ODDatabase *database = [[ODContainer defaultContainer] publicCloudDatabase];
        NSString *bookTitle = @"A tale of two cities";
        ODRecord *record1 = [[ODRecord alloc] initWithRecordID:[[ODRecordID alloc] initWithRecordType:@"book" name:@"book1"] data:nil];
        record1[@"title"] = bookTitle;
        ODRecord *record2 = [[ODRecord alloc] initWithRecordID:[[ODRecordID alloc] initWithRecordType:@"book" name:@"book2"] data:nil];
        record2[@"title"] = bookTitle;
        
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
                                                     @"_revision": @"revision1",
                                                     },
                                                 @{
                                                     @"_id": @"book/book2",
                                                     @"_type": @"error",
                                                     @"code": @(100),
                                                     @"message": @"An error.",
                                                     @"type": @"SaveError",
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
            __block NSUInteger errorHandlerCallCount = 0;
            
            [database saveRecords:@[record1, record2]
                completionHandler:^(NSArray *savedRecords, NSError *operationError) {
                    expect(savedRecords).to.haveCountOf(1);
                    expect(((ODRecord *)savedRecords[0]).recordID).to.equal(record1.recordID);
                    
                    if (errorHandlerCallCount == 1) {
                        done();
                    }
                }
            perRecordErrorHandler:^(ODRecord *record, NSError *error) {
                expect(record.recordID).to.equal(record2.recordID);
                errorHandlerCallCount++;
            }];
        });
        
    });
    
    it(@"delete record", ^{
        ODDatabase *database = [[ODContainer defaultContainer] publicCloudDatabase];
        ODRecordID *recordID = [[ODRecordID alloc] initWithRecordType:@"book" name:@"book1"];
        
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
                               expect(recordID.recordType).to.equal(@"book");
                               expect(recordID.recordName).to.equal(@"book1");
                               done();
                           });
                       }];
        });
        
    });
    
    it(@"delete records", ^{
        ODDatabase *database = [[ODContainer defaultContainer] publicCloudDatabase];
        ODRecordID *recordID1 = [[ODRecordID alloc] initWithRecordType:@"book" name:@"book1"];
        ODRecordID *recordID2 = [[ODRecordID alloc] initWithRecordType:@"book" name:@"book2"];
        
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
                                                     @"type": @"SaveError",
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
            __block NSUInteger errorHandlerCallCount = 0;
            
            [database deleteRecordsWithIDs:@[recordID1, recordID2]
                         completionHandler:^(NSArray *deletedRecordIDs, NSError *error) {
                             expect(deletedRecordIDs).to.contain(recordID1);
                             expect(deletedRecordIDs).to.haveCountOf(1);
                             
                             if (errorHandlerCallCount == 1) {
                                 done();
                             }
                         }
                     perRecordErrorHandler:^(ODRecordID *recordID, NSError *error) {
                         expect(recordID).to.equal(recordID2);
                         expect(error).toNot.beNil();
                         errorHandlerCallCount++;
                     }];
        });
        
    });
    
    it(@"perform query", ^{
        ODDatabase *database = [[ODContainer defaultContainer] publicCloudDatabase];
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
            ODQuery *query = [[ODQuery alloc] initWithRecordType:@"book" predicate:nil];
            [database performQuery:query inZoneWithID:nil completionHandler:^(NSArray *results, NSError *error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    expect(results).to.haveCountOf(1);
                    expect(((ODRecord *)results[0]).recordID.recordType).to.equal(@"book");
                    expect(((ODRecord *)results[0]).recordID.recordName).to.equal(@"book1");
                    done();
                });
            }];
        });
        
    });
    
});

SpecEnd