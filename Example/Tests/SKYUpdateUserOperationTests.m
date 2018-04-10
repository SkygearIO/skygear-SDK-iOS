//
//  SKYUpdateUserOperationTests.m
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
#import <SKYKit/SKYKit.h>

SpecBegin(SKYUpdateUserOperation)

    describe(@"Update User Operation", ^{
        NSString *apiKey = @"CORRECT_KEY";
        NSString *currentUserID = @"CORRECT_USER_ID";
        NSString *token = @"CORRECT_TOKEN";

        NSString *developerRoleName = @"Developer";

        SKYRole *developerRole = [SKYRole roleWithName:developerRoleName];

        SKYUserDeserializer *userDeserializer = [SKYUserDeserializer deserializer];

        __block SKYContainer *container = nil;
        beforeEach(^{
            container = [SKYContainer testContainer];
            [container.auth
                updateWithUserRecordID:currentUserID
                           accessToken:[[SKYAccessToken alloc] initWithTokenString:token]];
        });

        it(@"should create correct request", ^{
            SKYUser *user = [userDeserializer userWithDictionary:@{
                @"_id" : @"user_id",
                @"username" : @"user",
                @"email" : @"user@skygear.io",
                @"roles" : @[ developerRoleName ]
            }];
            SKYUpdateUserOperation *operation = [SKYUpdateUserOperation operationWithUser:user];
            [operation setContainer:container];
            [operation prepareForRequest];

            SKYRequest *request = operation.request;
            expect(request.action).to.equal(@"user:update");
            expect(request.accessToken.tokenString).to.equal(token);
            expect(request.payload[@"_id"]).to.equal(@"user_id");
            expect(request.payload[@"username"]).to.equal(@"user");
            expect(request.payload[@"email"]).to.equal(@"user@skygear.io");
            expect(request.payload[@"roles"]).to.haveACountOf(1);
            expect(request.payload[@"roles"][0]).to.equal(developerRoleName);
        });

        it(@"should handle success response correctly", ^{
            [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
                return YES;
            }
                withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
                    NSDictionary *payload = @{
                        @"result" : @{
                            @"_id" : @"user_id",
                            @"username" : @"user",
                            @"email" : @"user@skygear.io",
                            @"roles" : @[ developerRoleName ]
                        }
                    };
                    return [OHHTTPStubsResponse responseWithJSONObject:payload
                                                            statusCode:200
                                                               headers:nil];
                }];

            SKYUser *user = [userDeserializer userWithDictionary:@{
                @"_id" : @"user_id",
                @"username" : @"user",
                @"email" : @"user@skygear.io",
                @"roles" : @[ developerRoleName ]
            }];
            SKYUpdateUserOperation *operation = [SKYUpdateUserOperation operationWithUser:user];
            [operation setContainer:container];

            waitUntil(^(DoneCallback done) {
                operation.updateUserCompletionBlock = ^(SKYUser *user, NSError *error) {
                    expect(error).to.beNil();
                    expect(user).notTo.beNil();
                    expect(user.userID).to.equal(@"user_id");
                    expect(user.username).to.equal(@"user");
                    expect(user.email).to.equal(@"user@skygear.io");
                    expect(user.roles).to.haveACountOf(1);
                    expect([user hasRole:developerRole]).to.equal(YES);

                    done();
                };

                [container addOperation:operation];
            });
        });

        it(@"should handle deserialization error", ^{
            [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
                return YES;
            }
                withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
                    NSDictionary *payload = @{@"email" : @"user@skygear.io"};
                    return [OHHTTPStubsResponse responseWithJSONObject:payload
                                                            statusCode:200
                                                               headers:nil];
                }];

            SKYUser *user = [userDeserializer userWithDictionary:@{
                @"_id" : @"user_id",
                @"username" : @"user",
                @"email" : @"user@skygear.io",
                @"roles" : @[ developerRoleName ]
            }];
            SKYUpdateUserOperation *operation = [SKYUpdateUserOperation operationWithUser:user];
            [operation setContainer:container];

            waitUntil(^(DoneCallback done) {
                operation.updateUserCompletionBlock = ^(SKYUser *user, NSError *error) {
                    expect(user).to.beNil();
                    expect(error).notTo.beNil();
                    expect(error.code).to.equal(SKYErrorBadResponse);

                    done();
                };

                [container addOperation:operation];
            });
        });

        it(@"should throw exception for nil user passing", ^{
            SKYUpdateUserOperation *operation = [SKYUpdateUserOperation operationWithUser:nil];
            [operation setContainer:container];

            expect(^{
                [operation prepareForRequest];
            })
                .to.raise(NSInvalidArgumentException);
        });

        afterEach(^{
            [OHHTTPStubs removeAllStubs];
        });
    });

SpecEnd
