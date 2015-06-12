//
//  ODContainerTests.m
//  ODKit
//
//  Created by Patrick Cheung on 27/2/15.
//  Copyright (c) 2015 Kwok-kuen Cheung. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ODKit/ODKit.h>
#import <OHHTTPStubs/OHHTTPStubs.h>

#import "ODHexer.h"

#import "ODContainer_Private.h"


SpecBegin(ODContainer)

describe(@"config End Point address", ^{
    it(@"set the endPointAddress correctly", ^{
        ODContainer *container = [[ODContainer alloc] init];
        [container configAddress:@"newpoint.com:4321"];
        NSURL *expectEndPoint = [NSURL URLWithString:@"http://newpoint.com:4321/"];
        expect(container.endPointAddress).to.equal(expectEndPoint);
    });
});

describe(@"Default container", ^{
    it(@"give DB default ID", ^{
        ODContainer *container = [[ODContainer alloc] init];
        expect(container.publicCloudDatabase.databaseID).to.equal(@"_public");
        expect(container.privateCloudDatabase.databaseID).to.equal(@"_private");
    });
});

describe(@"save current user", ^{
    it(@"logout user", ^{
        ODContainer *container = [[ODContainer alloc] init];
        
        [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
            return YES;
        } withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
            NSDictionary *parameters = @{
                                         @"request_id": @"REQUEST_ID",
                                         @"result": @[
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
            [container logoutUserWithcompletionHandler:^(ODUserRecordID *user, NSError *error) {
                done();
            }];
        });
    });
    
    it(@"fetch record", ^{
        ODContainer *container = [[ODContainer alloc] init];
        [container updateWithUserRecordID:[ODUserRecordID recordIDWithUsername:@"user1"]
                              accessToken:[[ODAccessToken alloc] initWithTokenString:@"accesstoken1"]];
        
        container = [[ODContainer alloc] init];
        expect(container.currentUserRecordID.recordType).to.equal(@"user");
        expect(container.currentUserRecordID.recordName).to.equal(@"user1");
        expect(container.currentAccessToken.tokenString).to.equal(@"accesstoken1");
    });
    
    it(@"update with nil", ^{
        ODContainer *container = [[ODContainer alloc] init];
        [container updateWithUserRecordID:nil
                              accessToken:nil];
        
        container = [[ODContainer alloc] init];
        expect(container.currentUserRecordID).to.beNil();
        expect(container.currentAccessToken).to.beNil();
    });
    
    afterEach(^{
        NSString *appDomain = [[NSBundle mainBundle] bundleIdentifier];
        [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:appDomain];
    });
});

describe(@"register device", ^{
    it(@"new device", ^{
        ODContainer *container = [[ODContainer alloc] init];
        
        [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
            return YES;
        } withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
            NSDictionary *parameters = @{
                                         @"request_id": @"REQUEST_ID",
                                         @"result": @{@"id": @"DEVICE_ID"},
                                         };
            NSData *payload = [NSJSONSerialization dataWithJSONObject:parameters
                                                              options:0
                                                                error:nil];
            
            return [OHHTTPStubsResponse responseWithData:payload
                                              statusCode:200
                                                 headers:@{}];
        }];
        
        waitUntil(^(DoneCallback done) {
            [container registerRemoteNotificationDeviceToken:[ODHexer dataWithHexString:@"abcdef1234567890"]
                                           completionHandler:^(NSString *deviceID, NSError *error) {
                                               expect(deviceID).to.equal(@"DEVICE_ID");
                                               done();
                                           }];
        });
    });
    
    afterEach(^{
        NSString *appDomain = [[NSBundle mainBundle] bundleIdentifier];
        [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:appDomain];
    });
});

SpecEnd