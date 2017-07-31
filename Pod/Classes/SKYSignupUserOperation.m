//
//  SKYSignupUserOperation.m
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

#import "SKYSignupUserOperation.h"
#import "SKYOperation_Private.h"
#import "SKYRecordDeserializer.h"
#import "SKYRequest.h"

@implementation SKYSignupUserOperation

+ (instancetype)operationWithAuthData:(NSDictionary *)authData
                             password:(NSString *)password
                              profile:(NSDictionary *)profile
{
    return [[self alloc] initWithAuthData:authData password:password profile:profile];
}

+ (instancetype)operationWithAuthData:(NSDictionary *)authData password:(NSString *)password
{
    return [[self alloc] initWithAuthData:authData password:password profile:nil];
}

+ (instancetype)operationWithAnonymousUser
{
    return [[self alloc] initWithAnonymousUser];
}

- (instancetype)initWithAuthData:(NSDictionary *)authData
                        password:(NSString *)password
                         profile:(NSDictionary *)profile
{
    if ((self = [super init])) {
        self.authData = authData;
        self.password = password;
        self.profile = profile;
        self.anonymousUser = NO;
    }
    return self;
}

- (instancetype)initWithAnonymousUser
{
    if ((self = [super init])) {
        self.authData = nil;
        self.password = nil;
        self.profile = nil;
        self.anonymousUser = YES;
    }
    return self;
}

- (void)prepareForRequest
{
    NSMutableDictionary *payload = [[NSMutableDictionary alloc] init];
    if (!self.anonymousUser) {
        if (self.authData == nil) {
            @throw [NSException exceptionWithName:NSInvalidArgumentException
                                           reason:@"Auth data cannot be nil."
                                         userInfo:nil];
        }

        if (self.authData.allKeys.count == 0) {
            @throw [NSException exceptionWithName:NSInvalidArgumentException
                                           reason:@"Auth data cannot be empty."
                                         userInfo:nil];
        }

        if (self.password == nil) {
            @throw [NSException exceptionWithName:NSInvalidArgumentException
                                           reason:@"Password cannot be nil."
                                         userInfo:nil];
        }
    }

    if (self.authData) {
        payload[@"auth_data"] = self.authData;
    }
    if (self.password) {
        payload[@"password"] = self.password;
    }
    if (self.profile) {
        payload[@"profile"] = self.profile;
    }

    self.request = [[SKYRequest alloc] initWithAction:@"auth:signup" payload:payload];
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

- (void)setSignupCompletionBlock:(void (^)(SKYRecord *, SKYAccessToken *,
                                           NSError *))signupCompletionBlock
{
    if (signupCompletionBlock) {
        __weak typeof(self) weakSelf = self;
        self.completionBlock = ^{
            if (!weakSelf.error) {
                NSDictionary *response = weakSelf.response[@"result"];
                NSDictionary *profile = response[@"profile"];

                SKYRecord *user =
                    [[SKYRecordDeserializer deserializer] recordWithDictionary:profile];

                SKYAccessToken *accessToken =
                    [[SKYAccessToken alloc] initWithTokenString:response[@"access_token"]];

                NSLog(@"User created with UserRecordID %@ and AccessToken %@", response[@"_id"],
                      response[@"access_token"]);

                signupCompletionBlock(user, accessToken, nil);
            } else {
                signupCompletionBlock(nil, nil, weakSelf.error);
            }
        };
    } else {
        self.completionBlock = nil;
    }
}

@end
