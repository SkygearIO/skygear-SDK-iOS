//
//  SKYGetCurrentUserOperation.m
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

#import "SKYGetCurrentUserOperation.h"
#import "SKYOperationSubclass.h"
#import "SKYUserDeserializer.h"

@interface SKYGetCurrentUserOperation ()

@property (strong, nonatomic) SKYUserDeserializer *userDeserializer;

@end

@implementation SKYGetCurrentUserOperation

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.userDeserializer = [SKYUserDeserializer deserializer];
    }

    return self;
}

- (void)prepareForRequest
{
    self.request = [[SKYRequest alloc] initWithAction:@"me" payload:nil];
    self.request.accessToken = self.container.currentAccessToken;
}

- (void)handleResponse:(SKYResponse *)response
{
    NSDictionary *responseDictionary = response.responseDictionary;
    SKYUser *user = nil;
    SKYAccessToken *accessToken = nil;
    NSError *error = nil;

    if ([responseDictionary[@"result"] isKindOfClass:[NSDictionary class]]) {
        NSDictionary *resultDictionary = responseDictionary[@"result"];
        if (resultDictionary[@"user_id"] && resultDictionary[@"access_token"]) {
            accessToken =
                [[SKYAccessToken alloc] initWithTokenString:resultDictionary[@"access_token"]];

            user = [[SKYUserDeserializer deserializer] userWithDictionary:resultDictionary];
        } else {
            error = [self.errorCreator errorWithCode:SKYErrorBadResponse
                                             message:@"Get a non-user object is received."];
        }
    }

    if (self.getCurrentUserCompletionBlock) {
        self.getCurrentUserCompletionBlock(user, accessToken, error);
    }
}

- (void)handleRequestError:(NSError *)error
{
    if (self.getCurrentUserCompletionBlock) {
        self.getCurrentUserCompletionBlock(nil, nil, error);
    }
}

@end
