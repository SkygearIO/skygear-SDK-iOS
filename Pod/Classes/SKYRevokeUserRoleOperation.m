//
//  SKYRevokeUserRoleOperation.m
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

#import "SKYRevokeUserRoleOperation.h"

@implementation SKYRevokeUserRoleOperation

+ (instancetype)operationWithUserIDs:(NSArray<NSString *> *)userIDs
                           roleNames:(NSArray<NSString *> *)roleNames
{
    return [[self alloc] initWithUserIDs:userIDs roleNames:roleNames completionBlock:nil];
}

- (instancetype)initWithUserIDs:(NSArray<NSString *> *)userIDs
                      roleNames:(NSArray<NSString *> *)roleNames
                completionBlock:
                    (void (^)(NSArray<NSString *> *users, NSError *error))completionBlock
{
    self = [super init];
    if (self) {
        self.userIDs = userIDs;
        self.roleNames = roleNames;
        self.revokeUserRoleCompletionBlock = completionBlock;
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
    self.request = [[SKYRequest alloc] initWithAction:@"auth:role:revoke"
                                              payload:@{
                                                  @"users" : self.userIDs,
                                                  @"roles" : self.roleNames,
                                              }];
}

// override
- (void)handleRequestError:(NSError *)error
{
    if (self.revokeUserRoleCompletionBlock) {
        self.revokeUserRoleCompletionBlock(nil, error);
    }
}

// override
- (void)handleResponse:(SKYResponse *)aResponse
{
    if (self.revokeUserRoleCompletionBlock) {
        self.revokeUserRoleCompletionBlock(self.userIDs, nil);
    }
}

@end
