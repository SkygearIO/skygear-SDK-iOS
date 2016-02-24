//
//  SKYChangePasswordOperation.m
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

#import "SKYChangePasswordOperation.h"

#import "SKYOperationSubclass.h"
#import "SKYOperation_Private.h"

@implementation SKYChangePasswordOperation

- (instancetype)initWithOldPassword:(NSString *)oldPassword passwordToSet:(NSString *)newPassword
{
    if ((self = [super init])) {
        _oldPassword = [oldPassword copy];
        _passwordToSet = [newPassword copy];
    }
    return self;
}

+ (instancetype)operationWithOldPassword:(NSString *)oldPassword
                           passwordToSet:(NSString *)newPassword
{
    return [[self alloc] initWithOldPassword:oldPassword passwordToSet:newPassword];
}

- (void)prepareForRequest
{
    NSDictionary *payload = @{
        @"old_password" : self.oldPassword,
        @"password" : self.passwordToSet,
    };
    self.request = [[SKYRequest alloc] initWithAction:@"auth:password" payload:payload];
    self.request.accessToken = self.container.currentAccessToken;
}

- (void)operationWillStart
{
    [super operationWillStart];
    if (!self.container.currentAccessToken) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException
                                       reason:@"SKYContainer has no currently logged-in user"
                                     userInfo:nil];
    }
}

- (void)handleRequestError:(NSError *)error
{
    if (self.changePasswordCompletionBlock) {
        self.changePasswordCompletionBlock(nil, nil, error);
    }
}

- (void)handleResponse:(SKYResponse *)aResponse
{
    SKYUser *user = nil;
    SKYAccessToken *accessToken = nil;
    NSError *error = nil;

    NSDictionary *response = aResponse.responseDictionary[@"result"];
    if (response[@"user_id"] && response[@"access_token"]) {
        user = [SKYUser userWithUserID:response[@"user_id"]];
        accessToken = [[SKYAccessToken alloc] initWithTokenString:response[@"access_token"]];
    } else {
        error = [self.errorCreator errorWithResponseDictionary:response];
    }

    if (self.changePasswordCompletionBlock) {
        self.changePasswordCompletionBlock(user, accessToken, error);
    }
}

@end
