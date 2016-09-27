//
//  SKYLoginUserOperation.m
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

#import "SKYLoginUserOperation.h"
#import "SKYOperationSubclass.h"
#import "SKYOperation_Private.h"
#import "SKYRequest.h"
#import "SKYUserDeserializer.h"

@implementation SKYLoginUserOperation {
    NSDictionary *_authPayload;
}

- (NSString *)username
{
    return _authPayload[@"username"];
}

- (NSString *)password
{
    return _authPayload[@"password"];
}

- (NSString *)email
{
    return _authPayload[@"email"];
}

- (NSString *)provider
{
    return _authPayload[@"provider"];
}

- (NSString *)authenticationData
{
    return _authPayload[@"auth_data"];
}

- (instancetype)initWithAuthenticationPayload:(NSDictionary *)authPayload
{
    if ((self = [super init])) {
        _authPayload = authPayload ? [authPayload copy] : [NSMutableDictionary dictionary];
    }
    return self;
}

+ (instancetype)operationWithUsername:(NSString *)username password:(NSString *)password
{
    return [[SKYLoginUserOperation alloc] initWithAuthenticationPayload:@{
        @"username" : username,
        @"password" : password,
    }];
}

+ (instancetype)operationWithEmail:(NSString *)email password:(NSString *)password
{
    return [[SKYLoginUserOperation alloc] initWithAuthenticationPayload:@{
        @"email" : email,
        @"password" : password,
    }];
}

+ (instancetype)operationWithProvider:(NSString *)provider
                   authenticationData:(NSDictionary *)authData
{
    return [[SKYLoginUserOperation alloc] initWithAuthenticationPayload:@{
        @"provider" : provider,
        @"auth_data" : authData,
    }];
}

- (void)prepareForRequest
{
    NSMutableDictionary *payload = [_authPayload mutableCopy];
    self.request = [[SKYRequest alloc] initWithAction:@"auth:login" payload:payload];
    self.request.APIKey = self.container.APIKey;
}

- (void)operationWillStart
{
    [super operationWillStart];
    if (!self.container.APIKey) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException
                                       reason:@"SKYContainer is not configured with an API key."
                                     userInfo:nil];
    }
}

- (void)handleRequestError:(NSError *)error
{
    if (self.loginCompletionBlock) {
        self.loginCompletionBlock(nil, nil, error);
    }
}

- (void)handleResponse:(SKYResponse *)aResponse
{
    SKYUser *user = nil;
    SKYAccessToken *accessToken = nil;
    NSError *error = nil;

    NSDictionary *response = aResponse.responseDictionary[@"result"];
    if (response[@"user_id"] && response[@"access_token"]) {
        user = [[SKYUserDeserializer deserializer] userWithDictionary:response];
        accessToken = [[SKYAccessToken alloc] initWithTokenString:response[@"access_token"]];
    } else {
        error = [self.errorCreator errorWithCode:SKYErrorBadResponse
                                         message:@"Returned data does not contain expected data."];
    }

    if (!error) {
        NSLog(@"User logged in with UserRecordID %@.", user.userID);
    }

    if (self.loginCompletionBlock) {
        self.loginCompletionBlock(user, accessToken, error);
    }
}

@end
