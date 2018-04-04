//
//  SKYSetDisableUserOperation.m
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

#import "SKYSetDisableUserOperation.h"

#import "SKYDataSerialization.h"

@implementation SKYSetDisableUserOperation

+ (instancetype)disableOperationWithUserID:(NSString *)userID
                                   message:(NSString *_Nullable)message
                                    expiry:(NSDate *_Nullable)expiry
{
    return [[self alloc] initWithUserID:userID disabled:YES message:message expiry:expiry];
}

+ (instancetype)enableOperationWithUserID:(NSString *)userID
{
    return [[self alloc] initWithUserID:userID disabled:NO message:nil expiry:nil];
}

- (instancetype)initWithUserID:(NSString *)userID
                      disabled:(BOOL)disabled
                       message:(NSString *)message
                        expiry:(NSDate *)expiry
{
    self = [super init];
    if (self) {
        self.userID = [userID copy];
        self.disabled = disabled;
        self.message = [message copy];
        self.expiry = [expiry copy];
    }
    return self;
}

- (BOOL)requiresAPIKey
{
    return YES;
}

- (BOOL)requiresAccessToken
{
    return YES;
}

// override
- (void)prepareForRequest
{
    NSMutableDictionary *payload = [NSMutableDictionary
        dictionaryWithObjectsAndKeys:self.userID, @"auth_id", @(self.disabled), @"disabled", nil];
    if (self.message) {
        [payload setObject:self.message forKey:@"message"];
    }
    if (self.expiry) {
        [payload setObject:[SKYDataSerialization stringFromDate:self.expiry] forKey:@"expiry"];
    }

    self.request = [[SKYRequest alloc] initWithAction:@"auth:disable:set" payload:payload];
}

// override
- (void)handleRequestError:(NSError *)error
{
    if (self.setCompletionBlock) {
        self.setCompletionBlock(self.userID, error);
    }
}

// override
- (void)handleResponse:(SKYResponse *)aResponse
{
    if (self.setCompletionBlock) {
        self.setCompletionBlock(self.userID, nil);
    }
}

@end
