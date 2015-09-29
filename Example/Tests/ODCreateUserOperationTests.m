//
//  ODCreateUserOperationTests.m
//  ODKit
//
//  Created by Patrick Cheung on 26/2/15.
//  Copyright (c) 2015 Kwok-kuen Cheung. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ODKit/ODKit.h>
#import <OHHTTPStubs/OHHTTPStubs.h>

SpecBegin(ODCreateUserOperation)

describe(@"create", ^{
    __block ODContainer *container = nil;
    
    beforeEach(^{
        container = [[ODContainer alloc] init];
        [container configureWithAPIKey:@"API_KEY"];
        [container updateWithUserRecordID:[ODUserRecordID recordIDWithUsername:@"USER_ID"]
                              accessToken:[[ODAccessToken alloc] initWithTokenString:@"ACCESS_TOKEN"]];
    });
    
    it(@"normal user request", ^{
        ODCreateUserOperation *operation = [ODCreateUserOperation operationWithEmail:@"user@example.com" password:@"password"];
        operation.container = container;
        [operation prepareForRequest];
        ODRequest *request = operation.request;
        expect([request class]).to.beSubclassOf([ODRequest class]);
        expect(request.action).to.equal(@"auth:signup");
        expect(request.accessToken).to.beNil();
        expect(request.APIKey).to.equal(@"API_KEY");
        expect(request.payload[@"email"]).to.equal(@"user@example.com");
        expect(request.payload[@"password"]).to.equal(@"password");
    });
    
    it(@"anonymous user request", ^{
        ODCreateUserOperation *operation = [ODCreateUserOperation operationWithAnonymousUserAndPassword:@"password"];
        operation.container = container;
        [operation prepareForRequest];
        ODRequest *request = operation.request;
        expect([request class]).to.beSubclassOf([ODRequest class]);
        expect(request.action).to.equal(@"auth:signup");
        expect(request.accessToken).to.beNil();
        expect(request.APIKey).to.equal(@"API_KEY");
        expect(request.payload).notTo.contain(@"email");
    });
    
    it(@"make normal user request", ^{
        ODCreateUserOperation *operation = [ODCreateUserOperation operationWithEmail:@"user@example.com" password:@"password"];
        
        [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
            return YES;
        } withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
            NSDictionary *parameters = @{
                                         @"result":
                                             @{
                                                 @"user_id": @"USER_ID",
                                                 @"access_token": @"ACCESS_TOKEN",
                                                 },
                                         };
            NSData *payload = [NSJSONSerialization dataWithJSONObject:parameters
                                                              options:0
                                                                error:nil];
            
            return [OHHTTPStubsResponse responseWithData:payload
                                              statusCode:200
                                                 headers:@{}];
        }];
        
        waitUntil(^(DoneCallback done) {
            operation.createCompletionBlock = ^(ODUserRecordID *recordID, ODAccessToken *accessToken, NSError *error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    expect(recordID.recordType).to.equal(@"_user");
                    expect(recordID.recordName).to.equal(@"USER_ID");
                    expect(accessToken.tokenString).to.equal(@"ACCESS_TOKEN");
                    expect(error).to.beNil();
                    done();
                });
            };
            
            [container addOperation:operation];
        });
    });
    
    it(@"make anonymous user request", ^{
        ODCreateUserOperation *operation = [ODCreateUserOperation operationWithAnonymousUserAndPassword:@"password"];
        
        [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
            return YES;
        } withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
            NSDictionary *parameters = @{
                                         @"result":
                                             @{
                                                 @"user_id": @"USER_ID",
                                                 @"access_token": @"ACCESS_TOKEN",
                                                 },
                                         };
            NSData *payload = [NSJSONSerialization dataWithJSONObject:parameters
                                                              options:0
                                                                error:nil];
            
            return [OHHTTPStubsResponse responseWithData:payload
                                              statusCode:200
                                                 headers:@{}];
        }];
        
        waitUntil(^(DoneCallback done) {
            operation.createCompletionBlock = ^(ODUserRecordID *recordID, ODAccessToken *accessToken, NSError *error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    expect(recordID.recordType).to.equal(@"_user");
                    expect(recordID.recordName).to.equal(@"USER_ID");
                    expect(accessToken.tokenString).to.equal(@"ACCESS_TOKEN");
                    expect(error).to.beNil();
                    done();
                });
            };
            
            [container addOperation:operation];
        });
    });
    
    it(@"pass error", ^{
        ODCreateUserOperation *operation = [ODCreateUserOperation operationWithEmail:@"user@example.com" password:@"password"];
        [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
            return YES;
        } withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
            return [OHHTTPStubsResponse responseWithError:[NSError errorWithDomain:NSURLErrorDomain code:0 userInfo:nil]];
        }];
        
        waitUntil(^(DoneCallback done) {
            operation.createCompletionBlock = ^(ODUserRecordID *recordID, ODAccessToken *accessToken, NSError *error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    expect(error).toNot.beNil();
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
