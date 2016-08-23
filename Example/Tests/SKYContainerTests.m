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
#import <OHHTTPStubs/OHHTTPStubs.h>
#import <SKYKit/SKYKit.h>

#import "SKYHexer.h"

#import "SKYContainer_Private.h"
#import "SKYNotification_Private.h"

// an empty SKYOperation subclass that does nothing but call its completion handler
@interface MockOperation : SKYOperation

@property (nonatomic, copy) void (^mockCompletion)();

@end

@implementation MockOperation

- (void)prepareForRequest
{
    self.request = [[SKYRequest alloc] initWithAction:@"do:nothing" payload:@{}];
}

- (void)handleRequestError:(NSError *)error
{
    if (_mockCompletion) {
        _mockCompletion();
    }
}

- (void)handleResponse:(SKYResponse *)response
{
    if (_mockCompletion) {
        _mockCompletion();
    }
}

@end

SpecBegin(SKYContainer)

    describe(@"config End Point address", ^{
        it(@"set the endPointAddress correctly", ^{
            SKYContainer *container = [[SKYContainer alloc] init];
            [container configAddress:@"http://newpoint.com:4321/"];
            NSURL *expectEndPoint = [NSURL URLWithString:@"http://newpoint.com:4321/"];
            expect(container.endPointAddress).to.equal(expectEndPoint);
            expect(container.pubsubClient.endPointAddress)
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

describe(@"user login and signup", ^{
    __block SKYContainer *container = nil;
    __block void (^assertLoggedIn)(NSString *, NSError *) =
        ^(NSString *userRecordID, NSError *error) {
            expect(container.currentUserRecordID).to.equal(userRecordID);
            expect(error).to.beNil();
            expect(userRecordID).to.equal(@"UUID");
            expect(container.currentAccessToken.tokenString).to.equal(@"ACCESS_TOKEN");
        };

    beforeEach(^{
        container = [[SKYContainer alloc] init];
        [container configureWithAPIKey:@"API_KEY"];
        [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
            return YES;
        }
            withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
                NSDictionary *parameters = @{
                    @"user_id" : @"UUID",
                    @"access_token" : @"ACCESS_TOKEN",
                };
                NSData *payload = [NSJSONSerialization dataWithJSONObject:@{
                    @"result" : parameters
                }
                                                                  options:0
                                                                    error:nil];

                return [OHHTTPStubsResponse responseWithData:payload statusCode:200 headers:@{}];
            }];
    });

    it(@"signup user email and password", ^{
        waitUntil(^(DoneCallback done) {
            [container signupWithEmail:@"test@invalid"
                              password:@"secret"
                     completionHandler:^(SKYUser *user, NSError *error) {
                         assertLoggedIn(user.userID, error);
                         done();
                     }];
        });
    });

    it(@"signup username and password", ^{
        waitUntil(^(DoneCallback done) {
            [container signupWithUsername:@"test"
                                 password:@"secret"
                        completionHandler:^(SKYUser *user, NSError *error) {
                            assertLoggedIn(user.userID, error);
                            done();
                        }];
        });
    });

    it(@"login user email and password", ^{
        waitUntil(^(DoneCallback done) {
            [container loginWithEmail:@"test@invalid"
                             password:@"secret"
                    completionHandler:^(SKYUser *user, NSError *error) {
                        assertLoggedIn(user.userID, error);
                        done();
                    }];
        });
    });

    it(@"login username and password", ^{
        waitUntil(^(DoneCallback done) {
            [container loginWithUsername:@"test"
                                password:@"secret"
                       completionHandler:^(SKYUser *user, NSError *error) {
                           assertLoggedIn(user.userID, error);
                           done();
                       }];
        });
    });

    afterEach(^{
        [OHHTTPStubs removeAllStubs];

        NSString *appDomain = [[NSBundle mainBundle] bundleIdentifier];
        [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:appDomain];
    });
});

describe(@"get current user from server", ^{
    __block SKYContainer *container = nil;

    beforeEach(^{
        container = [[SKYContainer alloc] init];
        [container configureWithAPIKey:@"Correct API Key"];
    });

    it(@"can handle success response", ^{
        [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *_Nonnull request) {
            return YES;
        }
            withStubResponse:^OHHTTPStubsResponse *_Nonnull(NSURLRequest *_Nonnull request) {
                NSData *data = [NSJSONSerialization dataWithJSONObject:@{
                    @"result" : @{
                        @"user_id" : @"user-1",
                        @"username" : @"user1",
                        @"email" : @"user1@skygear.dev",
                        @"roles" : @[ @"Developer", @"Designer" ],
                        @"access_token" : @"token-1"
                    }
                }
                                                               options:0
                                                                 error:nil];
                return [OHHTTPStubsResponse responseWithData:data statusCode:200 headers:@{}];
            }];

        waitUntil(^(DoneCallback done) {
            [container getWhoAmIWithCompletionHandler:^(SKYUser *user, NSError *error) {
                expect(error).to.beNil();

                expect(user).notTo.beNil();
                expect(user.userID).to.equal(@"user-1");
                expect(user.username).to.equal(@"user1");
                expect(user.email).to.equal(@"user1@skygear.dev");
                expect(user.roles).to.haveLengthOf(2);
                expect(user.roles).to.contain([SKYRole roleWithName:@"Developer"]);
                expect(user.roles).to.contain([SKYRole roleWithName:@"Designer"]);

                done();
            }];
        });
    });

    it(@"can handle error response", ^{
        [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *_Nonnull request) {
            return YES;
        }
            withStubResponse:^OHHTTPStubsResponse *_Nonnull(NSURLRequest *_Nonnull request) {
                NSData *data = [NSJSONSerialization dataWithJSONObject:@{
                    @"error" : @{
                        @"name" : @"NotAuthenticated",
                        @"code" : @101,
                        @"message" : @"Authentication is needed to get current user"
                    }
                }
                                                               options:0
                                                                 error:nil];
                return [OHHTTPStubsResponse responseWithData:data statusCode:401 headers:@{}];
            }];

        waitUntil(^(DoneCallback done) {
            [container getWhoAmIWithCompletionHandler:^(SKYUser *user, NSError *error) {
                expect(user).to.beNil();
                expect(error).notTo.beNil();

                done();
            }];
        });
    });

    afterEach(^{
        [OHHTTPStubs removeAllStubs];

        NSString *appDomain = [[NSBundle mainBundle] bundleIdentifier];
        [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:appDomain];
    });
});

describe(@"save current user", ^{
    it(@"logout user", ^{
        SKYContainer *container = [[SKYContainer alloc] init];

        [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
            return YES;
        }
            withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
                NSDictionary *parameters = @{ @"request_id" : @"REQUEST_ID", @"result" : @[] };
                NSData *payload =
                    [NSJSONSerialization dataWithJSONObject:parameters options:0 error:nil];

                return [OHHTTPStubsResponse responseWithData:payload statusCode:200 headers:@{}];
            }];

        waitUntil(^(DoneCallback done) {
            [container logoutWithCompletionHandler:^(SKYUser *user, NSError *error) {
                done();
            }];
        });
    });

    it(@"fetch record", ^{
        SKYContainer *container = [[SKYContainer alloc] init];
        [container
            updateWithUserRecordID:@"user1"
                       accessToken:[[SKYAccessToken alloc] initWithTokenString:@"accesstoken1"]];

        container = [[SKYContainer alloc] init];
        expect(container.currentUserRecordID).to.equal(@"user1");
        expect(container.currentAccessToken.tokenString).to.equal(@"accesstoken1");
    });

    it(@"update with nil", ^{
        SKYContainer *container = [[SKYContainer alloc] init];
        [container updateWithUserRecordID:nil accessToken:nil];

        container = [[SKYContainer alloc] init];
        expect(container.currentUserRecordID).to.beNil();
        expect(container.currentAccessToken).to.beNil();
    });

    afterEach(^{
        [OHHTTPStubs removeAllStubs];

        NSString *appDomain = [[NSBundle mainBundle] bundleIdentifier];
        [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:appDomain];
    });
});

describe(@"register device", ^{
    __block id notificationObserver = nil;
    __block SKYContainer *container = nil;
    __block bool notificationPosted = NO;

    beforeEach(^{
        container = [[SKYContainer alloc] init];
        notificationObserver = [[NSNotificationCenter defaultCenter]
            addObserverForName:SKYContainerDidRegisterDeviceNotification
                        object:container
                         queue:[NSOperationQueue mainQueue]
                    usingBlock:^(NSNotification *note) {
                        notificationPosted = YES;
                    }];
    });

    it(@"new device", ^{
        [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
            return YES;
        }
            withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
                NSDictionary *parameters = @{
                    @"request_id" : @"REQUEST_ID",
                    @"result" : @{@"id" : @"DEVICE_ID"},
                };
                NSData *payload =
                    [NSJSONSerialization dataWithJSONObject:parameters options:0 error:nil];

                return [OHHTTPStubsResponse responseWithData:payload statusCode:200 headers:@{}];
            }];

        waitUntil(^(DoneCallback done) {
            [container
                registerRemoteNotificationDeviceToken:[SKYHexer
                                                          dataWithHexString:@"abcdef1234567890"]
                                    completionHandler:^(NSString *deviceID, NSError *error) {
                                        expect(deviceID).to.equal(@"DEVICE_ID");
                                        expect([container registeredDeviceID])
                                            .to.equal(@"DEVICE_ID");
                                        expect(notificationPosted).to.beTruthy();
                                        done();
                                    }];
        });
    });

    it(@"new device without device token", ^{
        [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
            return YES;
        }
            withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
                NSDictionary *parameters = @{
                    @"request_id" : @"REQUEST_ID",
                    @"result" : @{@"id" : @"DEVICE_ID"},
                };
                NSData *payload =
                    [NSJSONSerialization dataWithJSONObject:parameters options:0 error:nil];

                return [OHHTTPStubsResponse responseWithData:payload statusCode:200 headers:@{}];
            }];

        waitUntil(^(DoneCallback done) {
            [container registerDeviceCompletionHandler:^(NSString *deviceID, NSError *error) {
                expect(deviceID).to.equal(@"DEVICE_ID");
                expect([container registeredDeviceID]).to.equal(@"DEVICE_ID");
                expect(notificationPosted).to.beTruthy();
                done();
            }];
        });
    });

    afterEach(^{
        [OHHTTPStubs removeAllStubs];

        NSString *appDomain = [[NSBundle mainBundle] bundleIdentifier];
        [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:appDomain];

        [[NSNotificationCenter defaultCenter] removeObserver:notificationObserver];
        container = nil;
        notificationPosted = NO;
    });
});

describe(@"AuthenticationError callback", ^{
    __block SKYContainer *container = nil;

    beforeEach(^{
        container = [[SKYContainer alloc] init];
    });

    it(@"calls authentication error handler", ^{
        [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
            return YES;
        }
            withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
                return [OHHTTPStubsResponse responseWithJSONObject:@{
                    @"error" : @{
                        @"name" : @"AccessTokenNotAccepted",
                        @"code" : @(SKYErrorAccessTokenNotAccepted),
                        @"message" : @"authentication failed",
                    },
                }
                                                        statusCode:401
                                                           headers:nil];
            }];

        waitUntil(^(DoneCallback done) {
            [container setAuthenticationErrorHandler:^(SKYContainer *container,
                                                       SKYAccessToken *token, NSError *error) {
                done();
            }];
            [container addOperation:[[MockOperation alloc] init]];
        });
    });

    it(@"operation works without setting authentication error handler", ^{
        [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
            return YES;
        }
            withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
                return [OHHTTPStubsResponse responseWithJSONObject:@{
                    @"error" : @{
                        @"name" : @"AccessTokenNotAccepted",
                        @"code" : @(SKYErrorAccessTokenNotAccepted),
                        @"message" : @"authentication failed",
                    },
                }
                                                        statusCode:401
                                                           headers:nil];
            }];

        waitUntil(^(DoneCallback done) {
            MockOperation *op = [[MockOperation alloc] init];
            op.mockCompletion = ^{
                done();
            };
            [container addOperation:op];
        });
    });

    it(@"doesn't call authentication error handler on unmatched error", ^{
        [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
            return YES;
        }
            withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
                return [OHHTTPStubsResponse responseWithJSONObject:@{
                    @"error" : @{
                        @"name" : @"AccessKeyNotAccepted",
                        @"code" : @(SKYErrorAccessKeyNotAccepted),
                        @"message" : @"invalid authentication information",
                    },
                }
                                                        statusCode:401
                                                           headers:nil];
            }];

        waitUntil(^(DoneCallback done) {
            [container setAuthenticationErrorHandler:^(SKYContainer *container,
                                                       SKYAccessToken *token, NSError *error) {
                @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                               reason:@"Thou shalt not call"
                                             userInfo:nil];
            }];
            MockOperation *op = [[MockOperation alloc] init];
            op.mockCompletion = ^{
                done();
            };
            [container addOperation:op];
        });
    });

    afterEach(^{
        [OHHTTPStubs removeAllStubs];
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

    afterEach(^{
        [OHHTTPStubs removeAllStubs];
    });
});

describe(@"maintains a private pubsub", ^{
    __block SKYContainer *container = nil;
    __block id pubsub = nil;

    beforeEach(^{
        container = [[SKYContainer alloc] init];

        pubsub = OCMClassMock([SKYPubsub class]);
        container.internalPubsubClient = pubsub;
    });

    afterEach(^{
        container.internalPubsubClient = nil;
        pubsub = nil;
    });

    it(@"sets endpoint correct address", ^{
        OCMExpect(
            [pubsub setEndPointAddress:[NSURL URLWithString:@"ws://newpoint.com:4321/_/pubsub"]]);

        [container configAddress:@"http://newpoint.com:4321/"];

        OCMVerifyAll(pubsub);
    });

    it(@"subscribes without deviceID", ^{
        OCMExpect([pubsub subscribeTo:@"_sub_deviceid" handler:[OCMArg any]]);

        [container configAddress:@"http://newpoint.com:4321/"];

        [[NSUserDefaults standardUserDefaults] setObject:@"deviceid"
                                                  forKey:@"SKYContainerDeviceID"];
        [[NSNotificationCenter defaultCenter]
            postNotificationName:SKYContainerDidRegisterDeviceNotification
                          object:nil];

        OCMVerifyAllWithDelay(pubsub, 100);
    });

    it(@"subscribes with deviceID", ^{
        OCMExpect([pubsub subscribeTo:@"_sub_deviceid" handler:[OCMArg any]]);

        [[NSUserDefaults standardUserDefaults] setObject:@"deviceid"
                                                  forKey:@"SKYContainerDeviceID"];
        [container configAddress:@"http://newpoint.com:4321/"];

        OCMVerifyAll(pubsub);
    });

    describe(@"subscribed with delegate", ^{
        __block id delegate = nil;
        __block void (^handler)(NSDictionary *);

        beforeEach(^{
            delegate = OCMProtocolMock(@protocol(SKYContainerDelegate));
            container.delegate = delegate;

            [[NSUserDefaults standardUserDefaults] setObject:@"deviceid"
                                                      forKey:@"SKYContainerDeviceID"];
            OCMStub([pubsub subscribeTo:@"_sub_deviceid" handler:[OCMArg any]])
                .andDo(^(NSInvocation *invocation) {
                    void (^h)(NSDictionary *);
                    [invocation getArgument:&h atIndex:3];
                    handler = h;
                });
            [container configAddress:@"http://newpoint.com:4321/"];
        });

        afterEach(^{
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"SKYContainerDeviceID"];
            delegate = nil;
        });

        it(@"sends message to delegate", ^{
            OCMExpect([delegate container:container
                   didReceiveNotification:[OCMArg checkWithBlock:^BOOL(SKYNotification *n) {
                       return [n.subscriptionID isEqualToString:@"subscriptionid"];
                   }]]);

            handler(@{
                @"subscription-id" : @"subscriptionid",
                @"seq-num" : @1,
            });

            OCMVerifyAll(delegate);
        });

        it(@"deduplicates message to delegate", ^{
            [delegate setExpectationOrderMatters:YES];

            OCMExpect([delegate container:container
                   didReceiveNotification:[OCMArg checkWithBlock:^BOOL(SKYNotification *n) {
                       return [n.subscriptionID isEqualToString:@"subscription0"];
                   }]]);
            OCMExpect([delegate container:container
                   didReceiveNotification:[OCMArg checkWithBlock:^BOOL(SKYNotification *n) {
                       return [n.subscriptionID isEqualToString:@"subscription1"];
                   }]]);
            OCMExpect(
                [[delegate reject] container:[OCMArg any] didReceiveNotification:[OCMArg any]]);

            handler(@{
                @"subscription-id" : @"subscription0",
                @"seq-num" : @1,
            });
            handler(@{
                @"subscription-id" : @"subscription1",
                @"seq-num" : @2,
            });
            handler(@{
                @"subscription-id" : @"subscription1",
                @"seq-num" : @1,
            });

            OCMVerifyAll(delegate);
        });
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
        [container updateWithUserRecordID:currentUserId
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
            [container defineAdminRoles:@[
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
            [container setUserDefaultRole:@[
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

describe(@"manage user", ^{
    NSString *apiKey = @"CORRECT_KEY";
    NSString *currentUserId = @"CORRECT_USER_ID";
    NSString *token = @"CORRECT_TOKEN";

    __block SKYContainer *container = nil;

    beforeEach(^{
        container = [[SKYContainer alloc] init];
        [container configureWithAPIKey:apiKey];
        [container updateWithUserRecordID:currentUserId
                              accessToken:[[SKYAccessToken alloc] initWithTokenString:token]];
    });

    it(@"should be able to query by emails", ^{
        [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
            return YES;
        }
            withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
                NSDictionary *parameters = @{
                    @"result" : @[
                        @{
                           @"_id" : @"user/user0",
                           @"_type" : @"record",
                           @"_transient" : @{@"_email" : @"john.doe@example.com"},
                        },
                        @{
                           @"_id" : @"user/user1",
                           @"_type" : @"record",
                           @"_transient" : @{@"_email" : @"jane.doe@example.com"},
                        },
                    ],
                    @"info" : @{@"count" : @2}
                };
                NSData *payload =
                    [NSJSONSerialization dataWithJSONObject:parameters options:0 error:nil];

                return [OHHTTPStubsResponse responseWithData:payload statusCode:200 headers:@{}];
            }];

        waitUntil(^(DoneCallback done) {
            [container queryUsersByEmails:@[ @"john.doe@example.com", @"jane.doe@example.com" ]
                        completionHandler:^(NSArray<SKYRecord *> *users, NSError *error) {
                            expect([NSThread isMainThread]).to.beTruthy();

                            expect(error).to.beNil();
                            expect(users).to.haveACountOf(2);

                            expect(users[0].recordID.recordName).to.equal(@"user0");
                            expect([users[0].transient objectForKey:@"_email"])
                                .to.equal(@"john.doe@example.com");

                            expect(users[1].recordID.recordName).to.equal(@"user1");
                            expect([users[1].transient objectForKey:@"_email"])
                                .to.equal(@"jane.doe@example.com");

                            done();
                        }];
        });

    });

    it(@"should be able to update user", ^{
        SKYRole *developerRole = [SKYRole roleWithName:@"Developer"];

        [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
            return YES;
        }
            withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
                NSDictionary *payload = @{
                    @"result" : @{
                        @"_id" : @"user_id",
                        @"username" : @"user",
                        @"email" : @"user@skygear.io",
                        @"roles" : @[ developerRole.name ]
                    }
                };
                return
                    [OHHTTPStubsResponse responseWithJSONObject:payload statusCode:200 headers:nil];
            }];

        SKYUser *user = [SKYUser userWithUserID:@"user_id"];
        [user setUsername:@"user"];
        [user setEmail:@"user@skygear.io"];
        [user addRole:developerRole];

        waitUntil(^(DoneCallback done) {
            [container saveUser:user
                     completion:^(SKYUser *user, NSError *error) {
                         expect(error).to.beNil();
                         expect(user).notTo.beNil();
                         expect(user.userID).to.equal(@"user_id");
                         expect(user.username).to.equal(@"user");
                         expect(user.email).to.equal(@"user@skygear.io");
                         expect([user hasRole:developerRole]).to.equal(YES);

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
        [container updateWithUserRecordID:currentUserId
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
            [container defineCreationAccessWithRecordType:paintingRecordType
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

SpecEnd
