//
//  SKYAddRelationsOperation.m
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

#import "SKYAddRelationsOperation.h"
#import "SKYOperationSubclass.h"

#import "SKYDataSerialization.h"
#import "SKYError.h"

@implementation SKYAddRelationsOperation

- (instancetype)initWithType:(NSString *)relationType usersToRelated:(NSArray *)users
{
    if ((self = [super init])) {
        _relationType = relationType;
        _usersToRelate = users;
    }
    return self;
}

+ (instancetype)operationWithType:(NSString *)relationType
                   usersToRelated:(NSArray /* SKYUser */ *)users
{
    return [[self alloc] initWithType:relationType usersToRelated:users];
}

- (NSArray /* NSString */ *)userStringIDs
{
    NSMutableArray *ids = [NSMutableArray arrayWithCapacity:self.usersToRelate.count];
    for (SKYUser *user in self.usersToRelate) {
        [ids addObject:user.username];
    }
    return ids;
}

- (void)prepareForRequest
{
    NSMutableDictionary *payload = [@{ @"name" : self.relationType } mutableCopy];
    NSMutableArray *targets = [NSMutableArray array];
    for (SKYUser *user in self.usersToRelate) {
        [targets addObject:user.userID];
    }
    payload[@"targets"] = targets;
    self.request = [[SKYRequest alloc] initWithAction:@"relation:add" payload:payload];
    self.request.accessToken = self.container.currentAccessToken;
}

- (void)handleRequestError:(NSError *)error
{
    if (self.addRelationsCompletionBlock) {
        self.addRelationsCompletionBlock(nil, error);
    }
}

- (void)handleResponse:(SKYResponse *)responseObject
{
    NSDictionary *response = responseObject.responseDictionary;
    NSArray *result = response[@"result"];
    if (![result isKindOfClass:[NSArray class]]) {
        NSError *error = [self.errorCreator errorWithCode:SKYErrorBadResponse
                                                  message:@"Result is not an array or not exists."];
        if (self.addRelationsCompletionBlock) {
            self.addRelationsCompletionBlock(nil, error);
        }
        return;
    }

    NSDictionary *itemsByID = [self.class itemsByIDFromResult:result];

    NSMutableArray *savedUsers = [NSMutableArray arrayWithCapacity:itemsByID.count];
    NSMutableDictionary *errorsByStringUserID = [NSMutableDictionary dictionary];
    for (SKYUser *user in self.usersToRelate) {
        NSDictionary *itemDict = itemsByID[user.userID];

        NSString *returnedUserID = nil;
        NSError *error = nil;

        if (!itemDict.count) {
            error = [self.errorCreator errorWithCode:SKYErrorResourceNotFound
                                            userInfo:@{
                                                @"id" : user.userID,
                                                SKYErrorMessageKey : @"User missing in response",
                                            }];
        } else {
            NSString *itemType = itemDict[@"type"];
            if ([itemType isEqualToString:@"error"]) {
                error = [self.errorCreator errorWithResponseDictionary:itemDict[@"data"]];
            } else {
                returnedUserID = user.userID;
                if (returnedUserID == nil) {
                    error = [self.errorCreator
                        errorWithCode:SKYErrorInvalidData
                              message:@"User does not conform with expected format."];
                }
            }
        }

        NSAssert((returnedUserID == nil && error != nil) || (returnedUserID != nil && error == nil),
                 @"either one from user and error is not nil");

        if (self.perUserCompletionBlock) {
            self.perUserCompletionBlock(returnedUserID, error);
        }

        if (returnedUserID != nil) {
            [savedUsers addObject:returnedUserID];
        } else {
            errorsByStringUserID[user.userID] = error;
        }
    }

    if (self.addRelationsCompletionBlock) {
        NSError *operationError = nil;
        if (errorsByStringUserID.count) {
            operationError =
                [self.errorCreator partialErrorWithPerItemDictionary:errorsByStringUserID];
        }

        self.addRelationsCompletionBlock(savedUsers, operationError);
    }
}

+ (NSDictionary *)itemsByIDFromResult:(NSArray *)result
{
    NSMutableDictionary *itemsByID = [NSMutableDictionary dictionaryWithCapacity:result.count];
    for (NSDictionary *itemDict in result) {
        NSString *itemID = itemDict[@"id"];
        itemsByID[itemID] = itemDict;
    }
    return itemsByID;
}

@end
