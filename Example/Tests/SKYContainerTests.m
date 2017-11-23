//
//  SKYContainerTests.m
//  SKYKit
//
//  Copyright 2015 Oursky Ltd.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

#import <Foundation/Foundation.h>
#import <OHHTTPStubs/NSURLRequest+HTTPBodyTesting.h>
#import <OHHTTPStubs/OHHTTPStubs.h>
#import <SKYKit/SKYKit.h>

#import "SKYHexer.h"

#import "SKYAccessControl_Private.h"
#import "SKYContainer_Private.h"
#import "SKYNotification_Private.h"
#import "SKYPubsubContainer_Private.h"

SpecBegin(SKYContainer)

    describe(@"config End Point address", ^{
        it(@"set the endPointAddress correctly", ^{
            SKYContainer *container = [[SKYContainer alloc] init];
            [container configAddress:@"http://newpoint.com:4321/"];
            NSURL *expectEndPoint = [NSURL URLWithString:@"http://newpoint.com:4321/"];
            expect(container.endPointAddress).to.equal(expectEndPoint);
            expect(container.pubsub.endPointAddress)
                .to.equal([NSURL URLWithString:@"ws://newpoint.com:4321/pubsub"]);
        });
    });

describe(@"Default container", ^{
    it(@"give DB default ID", ^{
        SKYContainer *container = [[SKYContainer alloc] init];
        expect(container.publicCloudDatabase.databaseID).to.equal(@"_public");
        expect(container.privateCloudDatabase.databaseID).to.equal(@"_private");
    });
});

describe(@"calls lambda", ^{
    it(@"calls lambda no arguments", ^{
        SKYContainer *container = [[SKYContainer alloc] init];

        [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
            return YES;
        }
            withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
                NSDictionary *parameters =
                    @{ @"request_id" : @"REQUEST_ID",
                       @"result" : @{@"message" : @"hello bob"} };
                NSData *payload =
                    [NSJSONSerialization dataWithJSONObject:parameters options:0 error:nil];

                return [OHHTTPStubsResponse responseWithData:payload statusCode:200 headers:@{}];
            }];

        waitUntil(^(DoneCallback done) {
            [container callLambda:@"hello:world"
                completionHandler:^(NSDictionary *result, NSError *error) {
                    done();
                }];
        });
    });

    it(@"calls lambda with arguments", ^{
        SKYContainer *container = [[SKYContainer alloc] init];

        [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
            return YES;
        }
            withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
                NSData *body = request.OHHTTPStubs_HTTPBody;
                NSError *jsonError;
                NSDictionary *bodyJSON =
                    [NSJSONSerialization JSONObjectWithData:body
                                                    options:NSJSONReadingMutableContainers
                                                      error:&jsonError];
                expect(bodyJSON[@"action"]).to.equal(@"hello:world");
                expect(bodyJSON[@"args"]).to.equal(@[ @"this", @"is", @"bob" ]);

                NSDictionary *parameters =
                    @{ @"request_id" : @"REQUEST_ID",
                       @"result" : @{@"message" : @"hello bob"} };
                NSData *payload =
                    [NSJSONSerialization dataWithJSONObject:parameters options:0 error:nil];

                return [OHHTTPStubsResponse responseWithData:payload statusCode:200 headers:@{}];
            }];

        waitUntil(^(DoneCallback done) {
            [container callLambda:@"hello:world"
                        arguments:@[ @"this", @"is", @"bob" ]
                completionHandler:^(NSDictionary *result, NSError *error) {
                    done();
                }];
        });
    });

    it(@"calls lambda with array arguments", ^{
        SKYContainer *container = [[SKYContainer alloc] init];
        [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
            return YES;
        }
            withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
                NSData *body = request.OHHTTPStubs_HTTPBody;
                NSError *jsonError;
                NSDictionary *bodyJSON =
                    [NSJSONSerialization JSONObjectWithData:body
                                                    options:NSJSONReadingMutableContainers
                                                      error:&jsonError];
                expect(bodyJSON[@"action"]).to.equal(@"hello:world");
                expect(bodyJSON[@"args"]).to.equal(@[ @"this", @"is", @"bob" ]);

                NSDictionary *parameters =
                    @{ @"request_id" : @"REQUEST_ID",
                       @"result" : @{@"message" : @"hello bob"} };
                NSData *payload =
                    [NSJSONSerialization dataWithJSONObject:parameters options:0 error:nil];
                return [OHHTTPStubsResponse responseWithData:payload statusCode:200 headers:@{}];
            }];

        waitUntil(^(DoneCallback done) {
            [container callLambda:@"hello:world"
                        arguments:@[ @"this", @"is", @"bob" ]
                completionHandler:^(NSDictionary *result, NSError *error) {
                    done();
                }];
        });
    });

    it(@"calls lambda with dictionary arguments", ^{
        SKYContainer *container = [[SKYContainer alloc] init];
        [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
            return YES;
        }
            withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
                NSData *body = request.OHHTTPStubs_HTTPBody;
                NSError *jsonError;
                NSDictionary *bodyJSON =
                    [NSJSONSerialization JSONObjectWithData:body
                                                    options:NSJSONReadingMutableContainers
                                                      error:&jsonError];
                expect(bodyJSON[@"action"]).to.equal(@"hello:world");
                expect(bodyJSON[@"args"]).to.equal(@{ @"message" : @[ @"this", @"is", @"bob" ] });

                NSDictionary *parameters =
                    @{ @"request_id" : @"REQUEST_ID",
                       @"result" : @{@"message" : @"hello bob"} };
                NSData *payload =
                    [NSJSONSerialization dataWithJSONObject:parameters options:0 error:nil];
                return [OHHTTPStubsResponse responseWithData:payload statusCode:200 headers:@{}];
            }];

        waitUntil(^(DoneCallback done) {
            [container callLambda:@"hello:world"
                dictionaryArguments:@{
                    @"message" : @[ @"this", @"is", @"bob" ]
                }
                completionHandler:^(NSDictionary *result, NSError *error) {
                    done();
                }];
        });
    });

    afterEach(^{
        [OHHTTPStubs removeAllStubs];
    });
});

describe(@"manage roles", ^{
    NSString *apiKey = @"CORRECT_KEY";
    NSString *currentUserId = @"CORRECT_USER_ID";
    NSString *token = @"CORRECT_TOKEN";

    NSString *developerRoleName = @"Developer";
    NSString *testerRoleName = @"Tester";
    NSString *pmRoleName = @"Project Manager";

    __block SKYContainer *container = nil;

    beforeEach(^{
        container = [[SKYContainer alloc] init];
        [container configureWithAPIKey:apiKey];
        [container.auth updateWithUserRecordID:currentUserId
                                   accessToken:[[SKYAccessToken alloc] initWithTokenString:token]];
    });

    it(@"should handle define admin roles correctly", ^{
        [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
            return YES;
        }
            withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
                NSDictionary *response = @{
                    @"result" : @{@"roles" : @[ developerRoleName, testerRoleName, pmRoleName ]}
                };
                return [OHHTTPStubsResponse responseWithJSONObject:response
                                                        statusCode:200
                                                           headers:nil];
            }];

        waitUntil(^(DoneCallback done) {
            [container.auth defineAdminRoles:@[
                [SKYRole roleWithName:developerRoleName], [SKYRole roleWithName:testerRoleName],
                [SKYRole roleWithName:pmRoleName]
            ]
                                  completion:^(NSError *error) {
                                      expect(error).to.beNil();
                                      done();
                                  }];
        });
    });

    it(@"should handle set user default role correctly", ^{
        [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
            return YES;
        }
            withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
                NSDictionary *response = @{
                    @"result" : @{@"roles" : @[ developerRoleName, testerRoleName, pmRoleName ]}
                };
                return [OHHTTPStubsResponse responseWithJSONObject:response
                                                        statusCode:200
                                                           headers:nil];
            }];

        waitUntil(^(DoneCallback done) {
            [container.auth setUserDefaultRole:@[
                [SKYRole roleWithName:developerRoleName], [SKYRole roleWithName:testerRoleName],
                [SKYRole roleWithName:pmRoleName]
            ]
                                    completion:^(NSError *error) {
                                        expect(error).to.beNil();
                                        done();
                                    }];
        });
    });

    afterEach(^{
        [OHHTTPStubs removeAllStubs];
    });
});

describe(@"record creation access", ^{
    NSString *apiKey = @"CORRECT_KEY";
    NSString *currentUserId = @"CORRECT_USER_ID";
    NSString *token = @"CORRECT_TOKEN";

    NSString *painterRoleName = @"Painter";
    NSString *paintingRecordType = @"Painting";

    SKYRole *painterRole = [SKYRole roleWithName:painterRoleName];

    __block SKYContainer *container = nil;

    beforeEach(^{
        container = [[SKYContainer alloc] init];
        [container configureWithAPIKey:apiKey];
        [container.auth updateWithUserRecordID:currentUserId
                                   accessToken:[[SKYAccessToken alloc] initWithTokenString:token]];
    });

    it(@"can define creation access of record", ^{
        [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
            return YES;
        }
            withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
                NSDictionary *response = @{
                    @"result" : @{@"type" : paintingRecordType, @"roles" : @[ painterRoleName ]}
                };
                return [OHHTTPStubsResponse responseWithJSONObject:response
                                                        statusCode:200
                                                           headers:nil];
            }];

        waitUntil(^(DoneCallback done) {
            [container.publicCloudDatabase defineCreationAccessWithRecordType:paintingRecordType
                                                                        roles:@[ painterRole ]
                                                                   completion:^(NSError *error) {
                                                                       expect(error).to.beNil();
                                                                       done();
                                                                   }];
        });
    });

    afterEach(^{
        [OHHTTPStubs removeAllStubs];
    });
});

describe(@"record default access", ^{
    NSString *apiKey = @"CORRECT_KEY";
    NSString *currentUserId = @"CORRECT_USER_ID";
    NSString *token = @"CORRECT_TOKEN";

    NSString *painterRoleName = @"Painter";
    NSString *paintingRecordType = @"Painting";

    SKYRole *painterRole = [SKYRole roleWithName:painterRoleName];

    __block SKYContainer *container = nil;

    beforeEach(^{
        container = [[SKYContainer alloc] init];
        [container configureWithAPIKey:apiKey];
        [container.auth updateWithUserRecordID:currentUserId
                                   accessToken:[[SKYAccessToken alloc] initWithTokenString:token]];
    });

    it(@"can define default access of record", ^{
        [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
            return YES;
        }
            withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
                NSDictionary *response = @{
                    @"result" : @{
                        @"type" : paintingRecordType,
                        @"default_access" : @[
                            @{@"public" : @1, @"level" : @"read"},
                            @{@"role" : @"Painter", @"level" : @"write"}
                        ]
                    }
                };
                return [OHHTTPStubsResponse responseWithJSONObject:response
                                                        statusCode:200
                                                           headers:nil];
            }];

        waitUntil(^(DoneCallback done) {
            SKYAccessControl *acl = [SKYAccessControl accessControlWithEntries:@[
                [SKYAccessControlEntry readEntryForRole:painterRole],
                [SKYAccessControlEntry readEntryForPublic]
            ]];
            [container.publicCloudDatabase defineDefaultAccessWithRecordType:paintingRecordType
                                                                      access:acl
                                                                  completion:^(NSError *error) {
                                                                      expect(error).to.beNil();
                                                                      done();
                                                                  }];
        });
    });

    afterEach(^{
        [OHHTTPStubs removeAllStubs];
    });
});

SpecEnd
