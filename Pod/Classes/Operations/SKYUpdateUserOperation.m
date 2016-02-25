//
//  SKYUpdateUserOperation.m
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

#import "SKYUpdateUserOperation.h"
#import "SKYOperationSubclass.h"

@interface SKYUpdateUserOperation ()

@property (strong, readonly, nonatomic) SKYUserDeserializer *deserializer;

@end

@implementation SKYUpdateUserOperation

+ (instancetype)operationWithUser:(SKYUser *)user
{
    return [[SKYUpdateUserOperation alloc] initWithUser:user];
}

- (instancetype)initWithUser:(SKYUser *)user
{
    self = [super init];
    if (self) {
        _user = user;
        _deserializer = [SKYUserDeserializer deserializer];
    }

    return self;
}

// override
- (void)prepareForRequest
{
    if (!self.user) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException
                                       reason:@"User should not be nil"
                                     userInfo:nil];
    }

    NSMutableDictionary *payload = [[NSMutableDictionary alloc] init];
    [payload setObject:self.user.userID forKey:@"_id"];

    if (self.user.username) {
        [payload setObject:self.user.username forKey:@"username"];
    }

    if (self.user.email) {
        [payload setObject:self.user.email forKey:@"email"];
    }

    if (self.user.roles) {
        NSMutableArray<NSString *> *roleNames = [[NSMutableArray alloc] init];

        [self.user.roles
            enumerateObjectsUsingBlock:^(SKYRole *perRole, NSUInteger idx, BOOL *stop) {
                [roleNames addObject:perRole.name];
            }];

        [payload setObject:roleNames forKey:@"roles"];
    }

    self.request = [[SKYRequest alloc] initWithAction:@"user:update" payload:payload];

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

    if (!self.deserializer) {
        @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                       reason:@"User Deserializer is not set"
                                     userInfo:nil];
    }
}

// override
- (void)handleRequestError:(NSError *)error
{
    if (self.updateUserCompletionBlock) {
        self.updateUserCompletionBlock(nil, error);
    }
}

// override
- (void)handleResponse:(SKYResponse *)aResponse
{
    NSDictionary *result = aResponse.responseDictionary[@"result"];
    SKYUser *user = [self.deserializer userWithDictionary:result];
    NSError *error = nil;

    if (!user) {
        error = [self.errorCreator errorWithCode:SKYErrorBadResponse
                                         message:@"Response user cannot be deserialized"];
    }

    if (self.updateUserCompletionBlock) {
        self.updateUserCompletionBlock(user, error);
    }
}

@end
