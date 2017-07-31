//
//  SKYFetchUserRoleOperation.m
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

#import "SKYFetchUserRoleOperation.h"

#import "SKYOperationSubclass.h"

@implementation SKYFetchUserRoleOperation

+ (instancetype)operationWithUserIDs:(NSArray<NSString *> *)userIDs
{
    return [[self alloc] initWithUserIDs:userIDs completionBlock:nil];
}

- (instancetype)initWithUserIDs:(NSArray<NSString *> *)userIDs
                completionBlock:(void (^)(NSDictionary<NSString *, NSString *> *userRoles,
                                          NSError *error))completionBlock
{
    self = [super init];
    if (self) {
        self.userIDs = userIDs;
        self.fetchUserRoleCompletionBlock = completionBlock;
    }
    return self;
}

// override
- (void)prepareForRequest
{
    self.request =
        [[SKYRequest alloc] initWithAction:@"role:get" payload:@{@"users" : self.userIDs}];
    self.request.APIKey = self.container.APIKey;
    self.request.accessToken = self.container.auth.currentAccessToken;
}

// override
- (void)operationWillStart
{
    [super operationWillStart];
    if (!self.container.auth.currentAccessToken) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException
                                       reason:@"SKYContainer has no currently logged-in user"
                                     userInfo:nil];
    }
}

// override
- (void)handleRequestError:(NSError *)error
{
    if (self.fetchUserRoleCompletionBlock) {
        self.fetchUserRoleCompletionBlock(nil, error);
    }
}

// override
- (void)handleResponse:(SKYResponse *)aResponse
{
    NSMutableDictionary<NSString *, NSArray<NSString *> *> *userRoles =
        [NSMutableDictionary dictionary];
    NSError *error;

    NSDictionary *result = aResponse.responseDictionary[@"result"];
    for (NSString *userID in result) {
        id roleNames = result[userID];
        if (![roleNames isKindOfClass:[NSArray class]]) {
            userRoles = nil;
            error = [self.errorCreator errorWithResponseDictionary:result];
            break;
        }

        [userRoles setObject:roleNames forKey:userID];
    }

    if (self.fetchUserRoleCompletionBlock) {
        self.fetchUserRoleCompletionBlock(userRoles, error);
    }
}

@end
