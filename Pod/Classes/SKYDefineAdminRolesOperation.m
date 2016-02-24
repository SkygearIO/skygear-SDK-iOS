//
//  SKYDefineAdminRolesOperation.m
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

#import "SKYDefineAdminRolesOperation.h"

@implementation SKYDefineAdminRolesOperation

+ (instancetype)operationWithRoles:(NSArray<SKYRole *> *)roles
{
    return [[SKYDefineAdminRolesOperation alloc] initWithRoles:roles];
}

- (instancetype)initWithRoles:(NSArray<SKYRole *> *)roles
{
    self = [super init];
    if (self) {
        _roles = roles;
    }

    return self;
}

// override
- (void)prepareForRequest
{
    NSMutableArray<NSString *> *roleNames =
        [[NSMutableArray alloc] initWithCapacity:self.roles.count];
    [self.roles enumerateObjectsUsingBlock:^(SKYRole *obj, NSUInteger idx, BOOL *stop) {
        [roleNames addObject:obj.name];
    }];

    self.request =
        [[SKYRequest alloc] initWithAction:@"role:admin" payload:@{
            @"roles" : roleNames
        }];
    self.request.accessToken = self.container.currentAccessToken;
}

// override
- (void)operationWillStart
{
    [super operationWillStart];
    if (!self.container.currentAccessToken) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException
                                       reason:@"SKYContainer has no currently logged-in user"
                                     userInfo:nil];
    }
}

// override
- (void)handleRequestError:(NSError *)error
{
    if (self.defineAdminRolesCompletionBlock) {
        self.defineAdminRolesCompletionBlock(nil, error);
    }
}

// override
- (void)handleResponse:(SKYResponse *)aResponse
{
    NSDictionary *response = aResponse.responseDictionary[@"result"];
    NSArray<NSString *> *roleNames = [response objectForKey:@"roles"];

    NSMutableArray<SKYRole *> *roles = [[NSMutableArray alloc] initWithCapacity:roleNames.count];

    [roleNames enumerateObjectsUsingBlock:^(NSString *perRoleName, NSUInteger idx, BOOL *stop) {
        [roles addObject:[SKYRole roleWithName:perRoleName]];
    }];

    if (self.defineAdminRolesCompletionBlock) {
        self.defineAdminRolesCompletionBlock(roles, nil);
    }
}

@end
