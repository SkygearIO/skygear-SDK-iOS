//
//  SKYDefineCreationAccessOperation.m
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

#import "SKYDefineCreationAccessOperation.h"

@implementation SKYDefineCreationAccessOperation

+ (instancetype)operationWithRecordType:(NSString *)recordType roles:(NSArray<SKYRole *> *)roles
{
    return [[SKYDefineCreationAccessOperation alloc] initWithRecordType:recordType roles:roles];
}

- (instancetype)initWithRecordType:(NSString *)recordType roles:(NSArray<SKYRole *> *)roles
{
    self = [super init];
    if (self) {
        _recordType = recordType;
        _roles = roles;
    }

    return self;
}

// override
- (void)prepareForRequest
{
    if (!self.recordType) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException
                                       reason:@"Record type should not be nil"
                                     userInfo:nil];
    }

    NSMutableArray<NSString *> *roleNames = [[NSMutableArray alloc] init];
    [self.roles enumerateObjectsUsingBlock:^(SKYRole *perRole, NSUInteger idx, BOOL *stop) {
        [roleNames addObject:perRole.name];
    }];

    self.request = [[SKYRequest alloc] initWithAction:@"schema:access"
                                              payload:@{
                                                  @"type" : self.recordType,
                                                  @"create_roles" : roleNames
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
    if (self.defineCreationAccessCompletionBlock) {
        self.defineCreationAccessCompletionBlock(nil, nil, error);
    }
}

// override
- (void)handleResponse:(SKYResponse *)aResponse
{
    NSDictionary *result = [aResponse.responseDictionary objectForKey:@"result"];
    NSString *recordType = [result objectForKey:@"type"];
    NSArray<NSString *> *accessRoles = [result objectForKey:@"roles"];

    NSMutableArray<SKYRole *> *roles = [[NSMutableArray alloc] init];
    [accessRoles enumerateObjectsUsingBlock:^(NSString *perRoleName, NSUInteger idx, BOOL *stop) {
        [roles addObject:[SKYRole roleWithName:perRoleName]];
    }];

    if (self.defineCreationAccessCompletionBlock) {
        self.defineCreationAccessCompletionBlock(recordType, roles, nil);
    }
}
@end
