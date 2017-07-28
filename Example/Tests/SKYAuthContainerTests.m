//
//  SKYAuthContainerTests.m
//  SKYKit
//
//  Copyright 2017 Oursky Ltd.
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

#import "SKYAuthContainer_Private.h"

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

SpecBegin(SKYAuthContainer)

    describe(@"user login and signup", ^{
        __block SKYContainer *container = nil;
        __block void (^assertLoggedIn)(NSString *, NSError *) =
            ^(NSString *userRecordID, NSError *error) {
                expect(container.auth.currentUserRecordID).to.equal(userRecordID);
                expect(container.auth.currentUser.username).to.equal(@"john.doe");
                expect(container.auth.currentUser.email).to.equal(@"john.doe@example.com");
                expect(error).to.beNil();
                expect(userRecordID).to.equal(@"UUID");
                expect(container.auth.currentAccessToken.tokenString).to.equal(@"ACCESS_TOKEN");
            };

        beforeEach(^{
            container = [[SKYContainer alloc] init];
            container.defaultTimeoutInterval = 1.0;
            [container configureWithAPIKey:@"API_KEY"];
            [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
                NSString *path = [[request URL] path];
                return
                    [path isEqualToString:@"/auth/login"] || [path isEqualToString:@"/auth/signup"];
            }
                withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
                    expect(request.timeoutInterval).to.equal(1.0);
                    NSDictionary *parameters = @{
                        @"user_id" : @"UUID",
                        @"username" : @"john.doe",
                        @"email" : @"john.doe@example.com",
                        @"access_token" : @"ACCESS_TOKEN",
                    };
                    NSData *payload =
                        [NSJSONSerialization dataWithJSONObject:@{@"result" : parameters}
                                                        options:0
                                                          error:nil];

                    return
                        [OHHTTPStubsResponse responseWithData:payload statusCode:200 headers:@{}];
                }];
            SKYDatabase *database = [[SKYContainer defaultContainer] publicCloudDatabase];
            [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
                return [[[request URL] path] isEqualToString:@"/record/save"];
            }
                withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
                    NSDictionary *parameters = @{
                        @"request_id" : @"REQUEST_ID",
                        @"database_id" : database.databaseID,
                        @"result" : @[
                            @{
                                @"_id" : @"user/UUID",
                                @"_type" : @"record",
                                @"foo" : @"bar",
                            },
                        ]
                    };
                    NSData *payload =
                        [NSJSONSerialization dataWithJSONObject:parameters options:0 error:nil];

                    return
                        [OHHTTPStubsResponse responseWithData:payload statusCode:200 headers:@{}];
                }];
        });

        it(@"signup user email and password", ^{
            waitUntil(^(DoneCallback done) {
                [container.auth signupWithEmail:@"test@invalid"
                                       password:@"secret"
                              completionHandler:^(SKYUser *user, NSError *error) {
                                  assertLoggedIn(user.userID, error);
                                  done();
                              }];
            });
        });

        it(@"signup username and password", ^{
            waitUntil(^(DoneCallback done) {
                [container.auth signupWithUsername:@"test"
                                          password:@"secret"
                                 completionHandler:^(SKYUser *user, NSError *error) {
                                     assertLoggedIn(user.userID, error);
                                     done();
                                 }];
            });
        });

        it(@"signup user email, password and profile", ^{
            waitUntil(^(DoneCallback done) {
                [container.auth signupWithEmail:@"test@invalid"
                                       password:@"secret"
                              profileDictionary:@{@"foo" : @"bar"}
                              completionHandler:^(SKYRecord *record, NSError *error) {
                                  assertLoggedIn(record.recordID.recordName, error);
                                  done();
                              }];
            });
        });

        it(@"signup username, password and profile", ^{
            waitUntil(^(DoneCallback done) {
                [container.auth signupWithUsername:@"test"
                                          password:@"secret"
                                 profileDictionary:@{@"foo" : @"bar"}
                                 completionHandler:^(SKYRecord *record, NSError *error) {
                                     assertLoggedIn(record.recordID.recordName, error);
                                     done();
                                 }];
            });
        });

        it(@"login user email and password", ^{
            waitUntil(^(DoneCallback done) {
                [container.auth loginWithEmail:@"test@invalid"
                                      password:@"secret"
                             completionHandler:^(SKYUser *user, NSError *error) {
                                 assertLoggedIn(user.userID, error);
                                 done();
                             }];
            });
        });

        it(@"login username and password", ^{
            waitUntil(^(DoneCallback done) {
                [container.auth loginWithUsername:@"test"
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
            [container.auth getWhoAmIWithCompletionHandler:^(SKYUser *user, NSError *error) {
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
            [container.auth getWhoAmIWithCompletionHandler:^(SKYUser *user, NSError *error) {
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
            [container.auth logoutWithCompletionHandler:^(SKYUser *user, NSError *error) {
                done();
            }];
        });
    });

    it(@"fetch user with ID", ^{
        SKYContainer *container = [[SKYContainer alloc] init];
        [container.auth
            updateWithUserRecordID:@"user1"
                       accessToken:[[SKYAccessToken alloc] initWithTokenString:@"accesstoken1"]];

        container = [[SKYContainer alloc] init];
        expect(container.auth.currentUserRecordID).to.equal(@"user1");
        expect(container.auth.currentAccessToken.tokenString).to.equal(@"accesstoken1");
    });

    it(@"fetch user with User", ^{
        SKYContainer *container = [[SKYContainer alloc] init];
        SKYUser *user = [SKYUser userWithUserID:@"user1"];
        user.username = @"username1";
        [container.auth
            updateWithUser:user
               accessToken:[[SKYAccessToken alloc] initWithTokenString:@"accesstoken1"]];

        container = [[SKYContainer alloc] init];
        expect(container.auth.currentUserRecordID).to.equal(@"user1");
        expect(container.auth.currentUser.username).to.equal(@"username1");
        expect(container.auth.currentAccessToken.tokenString).to.equal(@"accesstoken1");
    });

    it(@"update with nil ID", ^{
        SKYContainer *container = [[SKYContainer alloc] init];
        [container.auth updateWithUserRecordID:nil accessToken:nil];

        container = [[SKYContainer alloc] init];
        expect(container.auth.currentUserRecordID).to.beNil();
        expect(container.auth.currentUser).to.beNil();
        expect(container.auth.currentAccessToken).to.beNil();
    });

    it(@"update with nil User", ^{
        SKYContainer *container = [[SKYContainer alloc] init];
        [container.auth updateWithUser:nil accessToken:nil];

        container = [[SKYContainer alloc] init];
        expect(container.auth.currentUserRecordID).to.beNil();
        expect(container.auth.currentUser).to.beNil();
        expect(container.auth.currentAccessToken).to.beNil();
    });

    afterEach(^{
        [OHHTTPStubs removeAllStubs];

        NSString *appDomain = [[NSBundle mainBundle] bundleIdentifier];
        [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:appDomain];
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
            [container.auth setAuthenticationErrorHandler:^(SKYContainer *container,
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
            [container.auth setAuthenticationErrorHandler:^(SKYContainer *container,
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

describe(@"manage user", ^{
    NSString *apiKey = @"CORRECT_KEY";
    NSString *currentUserId = @"CORRECT_USER_ID";
    NSString *token = @"CORRECT_TOKEN";

    __block SKYContainer *container = nil;

    beforeEach(^{
        container = [[SKYContainer alloc] init];
        [container configureWithAPIKey:apiKey];
        [container.auth updateWithUserRecordID:currentUserId
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
            [container.auth queryUsersByEmails:@[ @"john.doe@example.com", @"jane.doe@example.com" ]
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
            [container.auth saveUser:user
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

SpecEnd
