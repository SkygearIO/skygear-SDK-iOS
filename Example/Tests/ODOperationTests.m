//
//  ODOperationTests.m
//  ODKit
//
//  Created by Patrick Cheung on 25/2/15.
//  Copyright (c) 2015 Kwok-kuen Cheung. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ODKit/ODKit.h>
#import <OHHTTPStubs/OHHTTPStubs.h>

SpecBegin(ODOperation)

describe(@"request", ^{
    __block ODContainer *container = nil;
    
    beforeEach(^{
        container = [[ODContainer alloc] init];
        [container updateWithUserRecordID:[[ODUserRecordID alloc] initWithRecordName:@"USER_ID"]
                              accessToken:[[ODAccessToken alloc] initWithTokenString:@"ACCESS_TOKEN"]];
    });

    it(@"make http request", ^{
        NSString *action = @"auth:login";
        NSDictionary *payload = @{};
        
        ODRequest *request = [[ODRequest alloc] initWithAction:action payload:payload];
        ODOperation *operation = [[ODOperation alloc] initWithRequest:request];
        
        [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
            return YES;
        } withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
            expect(operation.executing).to.equal(YES);
            return [[OHHTTPStubsResponse alloc] initWithData:[NSData data]
                                                  statusCode:200
                                                     headers:@{}];
        }];
        
        waitUntil(^(DoneCallback done) {
            __block typeof(operation) blockOp = operation;
            operation.completionBlock = ^{
                expect(blockOp.finished).to.equal(YES);
                done();
            };
            NSOperationQueue *queue = [[NSOperationQueue alloc] init];
            [queue addOperation:operation];
        });
    });
    
    afterEach(^{
        [OHHTTPStubs removeAllStubs];
    });
});

SpecEnd
