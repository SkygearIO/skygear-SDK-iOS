//
//  SKYDatabaseTest.m
//  SkyKit
//
//  Created by Patrick Cheung on 27/2/15.
//  Copyright (c) 2015 Kwok-kuen Cheung. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SkyKit/SkyKit.h>
#import <OHHTTPStubs/OHHTTPStubs.h>

SpecBegin(SKYDatabase)

describe(@"database", ^{
    it(@"fetch record", ^{
        SKYDatabase *database = [[SKYContainer defaultContainer] publicCloudDatabase];
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
            [database fetchRecordWithID:[[SKYRecordID alloc] initWithRecordType:@"book" name:@"book1"]
                      completionHandler:^(SKYRecord *record, NSError *error) {
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
        SKYDatabase *database = [[SKYContainer defaultContainer] publicCloudDatabase];
        SKYRecordID *recordID1 = [[SKYRecordID alloc] initWithRecordType:@"book" name:@"book1"];
        SKYRecordID *recordID2 = [[SKYRecordID alloc] initWithRecordType:@"book" name:@"book2"];
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
                    perRecordErrorHandler:^(SKYRecordID *recordID, NSError *error) {
                        expect(recordID).to.equal(recordID2);
                        errorHandlerCallCount++;
                    }];
        });
        
    });
    
    it(@"modify record", ^{
        SKYDatabase *database = [[SKYContainer defaultContainer] publicCloudDatabase];
        NSString *bookTitle = @"A tale of two cities";
        SKYRecord *record = [[SKYRecord alloc] initWithRecordID:[[SKYRecordID alloc] initWithRecordType:@"book" name:@"book1"] data:nil];
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
                      completion:^(SKYRecord *record, NSError *error) {
                          dispatch_async(dispatch_get_main_queue(), ^{
                              expect(record.recordID.recordName).to.equal(@"book1");
                              expect(record.recordID.recordType).to.equal(@"book");
                              done();
                          });
                      }];
        });
        
    });
    
    it(@"modify records", ^{
        SKYDatabase *database = [[SKYContainer defaultContainer] publicCloudDatabase];
        NSString *bookTitle = @"A tale of two cities";
        SKYRecord *record1 = [[SKYRecord alloc] initWithRecordID:[[SKYRecordID alloc] initWithRecordType:@"book" name:@"book1"] data:nil];
        record1[@"title"] = bookTitle;
        SKYRecord *record2 = [[SKYRecord alloc] initWithRecordID:[[SKYRecordID alloc] initWithRecordType:@"book" name:@"book2"] data:nil];
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
                    expect(((SKYRecord *)savedRecords[0]).recordID).to.equal(record1.recordID);
                    
                    if (errorHandlerCallCount == 1) {
                        done();
                    }
                }
            perRecordErrorHandler:^(SKYRecord *record, NSError *error) {
                expect(record.recordID).to.equal(record2.recordID);
                errorHandlerCallCount++;
            }];
        });
        
    });
    
    it(@"delete record", ^{
        SKYDatabase *database = [[SKYContainer defaultContainer] publicCloudDatabase];
        SKYRecordID *recordID = [[SKYRecordID alloc] initWithRecordType:@"book" name:@"book1"];
        
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
                       completionHandler:^(SKYRecordID *recordID, NSError *error) {
                           dispatch_async(dispatch_get_main_queue(), ^{
                               expect(recordID.recordType).to.equal(@"book");
                               expect(recordID.recordName).to.equal(@"book1");
                               done();
                           });
                       }];
        });
        
    });
    
    it(@"delete records", ^{
        SKYDatabase *database = [[SKYContainer defaultContainer] publicCloudDatabase];
        SKYRecordID *recordID1 = [[SKYRecordID alloc] initWithRecordType:@"book" name:@"book1"];
        SKYRecordID *recordID2 = [[SKYRecordID alloc] initWithRecordType:@"book" name:@"book2"];
        
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
                     perRecordErrorHandler:^(SKYRecordID *recordID, NSError *error) {
                         expect(recordID).to.equal(recordID2);
                         expect(error).toNot.beNil();
                         errorHandlerCallCount++;
                     }];
        });
        
    });
    
    it(@"perform query", ^{
        SKYDatabase *database = [[SKYContainer defaultContainer] publicCloudDatabase];
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
            SKYQuery *query = [[SKYQuery alloc] initWithRecordType:@"book" predicate:nil];
            [database performQuery:query completionHandler:^(NSArray *results, NSError *error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    expect(results).to.haveCountOf(1);
                    expect(((SKYRecord *)results[0]).recordID.recordType).to.equal(@"book");
                    expect(((SKYRecord *)results[0]).recordID.recordName).to.equal(@"book1");
                    done();
                });
            }];
        });
        
    });
    
});

SpecEnd
