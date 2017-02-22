//
//  SKYLambdaOperation.m
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

#import "SKYLambdaOperation.h"
#import "SKYOperationSubclass.h"

@implementation SKYLambdaOperation

- (instancetype)initWithAction:(NSString *)action arrayArguments:(NSArray *)arguments
{
    self = [super init];
    if (self) {
        _action = [action copy];
        _arrayArguments = [arguments copy];
    }
    return self;
}

- (instancetype)initWithAction:(NSString *)action dictionaryArguments:(NSDictionary *)arguments
{
    self = [super init];
    if (self) {
        _action = [action copy];
        _dictionaryArguments = [arguments copy];
    }
    return self;
}

+ (instancetype)operationWithAction:(NSString *)action arrayArguments:(NSArray *)arguments
{
    return [[self alloc] initWithAction:action arrayArguments:arguments];
}

+ (instancetype)operationWithAction:(NSString *)action dictionaryArguments:(NSDictionary *)arguments
{
    return [[self alloc] initWithAction:action dictionaryArguments:arguments];
}

- (void)prepareForRequest
{
    NSDictionary *payload = @{ @"args" : _arrayArguments ? _arrayArguments : _dictionaryArguments };
    self.request = [[SKYRequest alloc] initWithAction:self.action payload:payload];

    // Lambda request may not be user-authenticated. Therefore an API key
    // is also supplied.
    self.request.APIKey = self.container.APIKey;
    self.request.accessToken = self.container.currentAccessToken;
}

- (void)handleRequestError:(NSError *)error
{
    if (self.lambdaCompletionBlock) {
        self.lambdaCompletionBlock(nil, error);
    }
}

- (void)handleResponse:(SKYResponse *)responseObject
{
    NSDictionary *response = responseObject.responseDictionary;
    NSDictionary *resultDictionary = nil;
    NSError *error = nil;

    NSDictionary *responseDictionary = response[@"result"];
    if ([responseDictionary isKindOfClass:[NSDictionary class]]) {
        resultDictionary = responseDictionary;
    } else {
        error = [self.errorCreator errorWithCode:SKYErrorBadResponse
                                         message:@"Result is not an array or not exists."];
    }

    if (self.lambdaCompletionBlock) {
        self.lambdaCompletionBlock(resultDictionary, error);
    }
}

@end
