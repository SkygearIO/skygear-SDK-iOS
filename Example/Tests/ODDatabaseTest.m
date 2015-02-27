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
                          });
                          done();
                      }];
        });
        
    });
});

SpecEnd