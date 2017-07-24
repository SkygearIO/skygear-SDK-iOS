//
//  SKYGetUserRoleOperation.m
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

#import "SKYGetUserRoleOperation.h"

#import "SKYOperationSubclass.h"

@implementation SKYGetUserRoleOperation

+ (instancetype)operationWithUsers:(NSArray<SKYRecord *> *)users
{
    return [[self alloc] initWithUsers:users completionBlock:nil];
}

- (instancetype)initWithUsers:(NSArray<SKYRecord *> *)users
              completionBlock:(void (^)(NSDictionary<NSString *, SKYRole *> *userRoles,
                                        NSError *error))completionBlock
{
    self = [super init];
    if (self) {
        self.users = users;
        self.getUserRoleCompletionBlock = completionBlock;
    }
    return self;
}

- (NSArray<NSString *> *)userIDs
{
    NSMutableArray<NSString *> *userIDs = [NSMutableArray arrayWithCapacity:self.users.count];
    for (SKYRecord *user in self.users) {
        if (![user.recordID.recordType isEqualToString:@"user"]) {
            @throw [NSException exceptionWithName:NSInvalidArgumentException
                                           reason:@"Record type should be user"
                                         userInfo:nil];
        }

        [userIDs addObject:user.recordID.recordName];
    }

    return userIDs;
}

// override
- (void)prepareForRequest
{
    self.request =
        [[SKYRequest alloc] initWithAction:@"role:get" payload:@{
            @"users" : self.userIDs
        }];
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
    if (self.getUserRoleCompletionBlock) {
        self.getUserRoleCompletionBlock(nil, error);
    }
}

// override
- (void)handleResponse:(SKYResponse *)aResponse
{
    NSMutableDictionary<NSString *, NSArray<SKYRole *> *> *userRoles =
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

        NSMutableArray<SKYRole *> *roles = [NSMutableArray arrayWithCapacity:[roleNames count]];
        for (NSString *roleName in roleNames) {
            [roles addObject:[SKYRole roleWithName:roleName]];
        }

        [userRoles setObject:roles forKey:userID];
    }

    if (self.getUserRoleCompletionBlock) {
        self.getUserRoleCompletionBlock(userRoles, error);
    }
}

@end
