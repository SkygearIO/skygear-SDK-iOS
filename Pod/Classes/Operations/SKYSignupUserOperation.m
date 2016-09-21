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
#import "SKYRequest.h"
#import "SKYUserDeserializer.h"

@implementation SKYSignupUserOperation

+ (instancetype)operationWithUsername:(NSString *)username password:(NSString *)password
{
    return [[self alloc] initWithEmail:nil username:username password:password];
}

+ (instancetype)operationWithEmail:(NSString *)email password:(NSString *)password
{
    return [[self alloc] initWithEmail:email username:nil password:password];
}

+ (instancetype)operationWithAnonymousUserAndPassword:(NSString *)password
{
    return [[self alloc] initWithAnonymousUserAndPassword:password];
}

- (instancetype)initWithEmail:(NSString *)email
                     username:(NSString *)username
                     password:(NSString *)password
{
    if ((self = [super init])) {
        self.username = username;
        self.email = email;
        self.password = password;
        self.anonymousUser = NO;
    }
    return self;
}

- (instancetype)initWithAnonymousUserAndPassword:(NSString *)password
{
    if ((self = [super init])) {
        self.username = nil;
        self.email = nil;
        self.password = nil;
        self.anonymousUser = YES;
    }
    return self;
}

- (void)prepareForRequest
{
    NSMutableDictionary *payload = [[NSMutableDictionary alloc] init];
    if (!self.anonymousUser) {
        if (self.username == nil && self.email == nil) {
            @throw [NSException
                exceptionWithName:NSInvalidArgumentException
                           reason:@"Username and email cannot be both nil for anonymous user."
                         userInfo:nil];
        }
        if (self.password == nil) {
            @throw [NSException exceptionWithName:NSInvalidArgumentException
                                           reason:@"Password cannot be nil for anonymous user."
                                         userInfo:nil];
        }
    }
    if (self.username) {
        payload[@"username"] = self.username;
    }
    if (self.email) {
        payload[@"email"] = self.email;
    }
    if (self.password) {
        payload[@"password"] = self.password;
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

- (void)setSignupCompletionBlock:(void (^)(SKYUser *, SKYAccessToken *,
                                           NSError *))signupCompletionBlock
{
    if (signupCompletionBlock) {
        __weak typeof(self) weakSelf = self;
        self.completionBlock = ^{
            if (!weakSelf.error) {
                NSDictionary *response = weakSelf.response[@"result"];

                SKYUser *user = [[SKYUserDeserializer deserializer] userWithDictionary:response];

                SKYAccessToken *accessToken =
                    [[SKYAccessToken alloc] initWithTokenString:response[@"access_token"]];

                NSLog(@"User created with UserRecordID %@ and AccessToken %@", response[@"user_id"],
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
