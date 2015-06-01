//
//  ODFetchRelationsOperationTests.m
//  ODKit
//
//  Created by Rick Mak on 18/5/15.
//  Copyright (c) 2015 Oursky. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ODKit/ODKit.h>
#import <OHHTTPStubs/OHHTTPStubs.h>

SpecBegin(ODFetchRelationsOperation)

describe(@"modify", ^{
    __block ODContainer *container = nil;
    __block ODDatabase *database = nil;
    
    beforeEach(^{
        container = [[ODContainer alloc] init];
        [container updateWithUserRecordID:[ODUserRecordID recordIDWithUsername:@"USER_ID"]
                              accessToken:[[ODAccessToken alloc] initWithTokenString:@"ACCESS_TOKEN"]];
        database = [container publicCloudDatabase];
    });
    
    it(@"make ODRequest", ^{
        ODQueryRelationsOperation *operation = [[ODQueryRelationsOperation alloc] initWithType:@"follow" direction:ODRelationDirectionActive];
        operation.container = container;
        [operation prepareForRequest];
        ODRequest *request = operation.request;
        expect([request class]).to.beSubclassOf([ODRequest class]);
        expect(request.action).to.equal(@"relation:fetch");
        expect(request.payload[@"name"]).to.equal(@"follow");
        expect(request.payload[@"direction"]).to.equal(@"active");
        expect(request.accessToken).to.equal(container.currentAccessToken);
    });
    
    it(@"make request", ^{
        ODUserRecordID *userID = [ODUserRecordID recordIDWithUsername:@"user1002"];
        ODQueryRelationsOperation *operation = [[ODQueryRelationsOperation alloc] initWithType:@"follow"
                                                                                  direction:ODRelationDirectionPassive];
        
        [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
            return YES;
        } withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
            NSDictionary *parameters = @{
                                         @"request_id": @"REQUEST_ID",
                                         @"result": @[
                                                 @{
                                                     @"_id": @"user/user1001",
                                                     @"_type": @"user",
                                                     @"_revision": @"revision1",
                                                     @"email": @"user1@example.com",
                                                     },
                                                 @{
                                                     @"_id": @"user/user1002",
                                                     @"_type": @"user",
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
            operation.queryUsersCompletionBlock = ^(NSArray *users, NSError *operationError) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    expect([users class]).to.beSubclassOf([NSArray class]);
                    expect(users).to.haveCountOf(2);
                    expect(users[0][@"email"]).to.equal(@"user1@example.com");
                    expect([users[1] recordID]).to.equal(userID);
                    done();
                });
            };
            
            [container addOperation:operation];
        });
    });
    
    afterEach(^{
        [OHHTTPStubs removeAllStubs];
    });
});

SpecEnd
