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
#import "SKYAuthOperation_Private.h"
#import "SKYRequest.h"

@implementation SKYLoginUserOperation {
    NSDictionary *_authPayload;
}

- (NSDictionary *)authData
{
    return _authPayload[@"auth_data"];
}

- (NSString *)password
{
    return _authPayload[@"password"];
}

- (NSString *)provider
{
    return _authPayload[@"provider"];
}

- (NSDictionary *)providerAuthData
{
    return _authPayload[@"provider_auth_data"];
}

- (instancetype)initWithAuthenticationPayload:(NSDictionary *)authPayload
{
    if ((self = [super init])) {
        _authPayload = authPayload ? [authPayload copy] : [NSMutableDictionary dictionary];
    }
    return self;
}

+ (instancetype)operationWithAuthData:(NSDictionary *)authData password:(NSString *)password
{
    return [[SKYLoginUserOperation alloc] initWithAuthenticationPayload:@{
        @"auth_data" : authData,
        @"password" : password,
    }];
}

+ (instancetype)operationWithProvider:(NSString *)provider
                     providerAuthData:(NSDictionary *)providerAuthData
{
    return [[SKYLoginUserOperation alloc] initWithAuthenticationPayload:@{
        @"provider" : provider,
        @"provider_auth_data" : providerAuthData,
    }];
}

- (BOOL)requiresAPIKey
{
    return YES;
}

- (void)prepareForRequest
{
    NSMutableDictionary *payload = [_authPayload mutableCopy];
    self.request = [[SKYRequest alloc] initWithAction:@"auth:login" payload:payload];
}

- (void)handleRequestError:(NSError *)error
{
    if (self.loginCompletionBlock) {
        self.loginCompletionBlock(nil, nil, error);
    }
}

- (void)handleAuthResponseWithUser:(SKYRecord *)record
                       accessToken:(SKYAccessToken *)accessToken
                             error:(NSError *)error
{
    if (self.loginCompletionBlock) {
        self.loginCompletionBlock(record, accessToken, error);
    }
}

@end
