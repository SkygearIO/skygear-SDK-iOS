//
//  SKYRemoveRelationsOperation.m
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

#import "SKYRemoveRelationsOperation.h"
#import "SKYOperationSubclass.h"

#import "SKYDataSerialization.h"
#import "SKYError.h"

@implementation SKYRemoveRelationsOperation

- (instancetype)initWithType:(NSString *)relationType usersToRemove:(NSArray *)users
{
    if ((self = [super init])) {
        _relationType = relationType;
        _usersToRemove = users;
    }
    return self;
}

+ (instancetype)operationWithType:(NSString *)relationType usersToRemove:(NSArray *)users
{
    return [[self alloc] initWithType:relationType usersToRemove:users];
}

- (void)prepareForRequest
{
    NSMutableDictionary *payload = [@{ @"name" : self.relationType } mutableCopy];
    NSMutableArray *targets = [NSMutableArray array];
    for (SKYUser *user in self.usersToRemove) {
        [targets addObject:user.userID];
    }
    payload[@"targets"] = targets;
    self.request = [[SKYRequest alloc] initWithAction:@"relation:delete" payload:payload];
    self.request.accessToken = self.container.currentAccessToken;
}

- (NSArray *)processResultArray:(NSArray *)result operationError:(NSError **)operationError
{
    NSMutableArray *deletedUserIDs = [NSMutableArray array];
    NSMutableDictionary *errorByUserID = [NSMutableDictionary dictionary];
    [result enumerateObjectsUsingBlock:^(NSDictionary *obj, NSUInteger idx, BOOL *stop) {
        NSString *userRecordID = nil;
        NSError *error = nil;

        NSString *userID = obj[@"id"];
        NSString *objType = obj[@"type"];
        if ([objType isEqual:@"error"]) {
            NSError *error = [self.errorCreator errorWithResponseDictionary:obj[@"data"]];
            errorByUserID[userID] = error;
        } else if (userID.length) {
            userRecordID = userID;
            [deletedUserIDs addObject:userRecordID];
        }

        if (userRecordID == nil && error == nil) {
            error = [self.errorCreator errorWithCode:SKYErrorInvalidData
                                             message:@"Per-item response is malformed"];
        }

        if (self.perUserCompletionBlock) {
            self.perUserCompletionBlock(userRecordID, error);
        }
    }];

    if (errorByUserID.count) {
        *operationError = [self.errorCreator partialErrorWithPerItemDictionary:errorByUserID];
    }
    return deletedUserIDs;
}

- (void)handleRequestError:(NSError *)error
{
    if (self.removeRelationsCompletionBlock) {
        self.removeRelationsCompletionBlock(nil, error);
    }
}

- (void)handleResponse:(SKYResponse *)responseObject
{
    NSDictionary *response = responseObject.responseDictionary;
    NSArray *result = response[@"result"];
    NSArray *userIDs = nil;
    NSError *error = nil;
    if ([result isKindOfClass:[NSArray class]]) {
        userIDs = [self processResultArray:result operationError:&error];
    } else {
        userIDs = [NSArray array];
        error = [self.errorCreator errorWithCode:SKYErrorBadResponse
                                         message:@"Result is not an array or not exists."];
    }
    if (self.removeRelationsCompletionBlock) {
        self.removeRelationsCompletionBlock(userIDs, error);
    }
}

@end
