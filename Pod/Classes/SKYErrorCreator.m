//
//  SKYErrorCreator.m
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

#import "SKYErrorCreator.h"
#import "SKYOperation.h"

@implementation SKYErrorCreator {
    NSMutableDictionary *_defaultUserInfo;
}

- (instancetype)init
{
    return [self initWithDefaultErrorDomain:SKYOperationErrorDomain];
}

- (instancetype)initWithDefaultErrorDomain:(NSString *)errorDomain
{
    self = [super init];
    if (self) {
        _errorDomain = [errorDomain copy];
        _defaultUserInfo = [NSMutableDictionary dictionary];
    }
    return self;
}

- (NSDictionary *)defaultUserInfo
{
    return [_defaultUserInfo copy];
}

- (void)setDefaultUserInfoObject:(id)obj forKey:(NSString *)key
{
    [_defaultUserInfo setObject:obj forKey:key];
}

- (NSError *)errorWithCode:(SKYErrorCode)code
{
    return [self errorWithCode:code userInfo:nil];
}

- (NSError *)errorWithCode:(SKYErrorCode)code message:(NSString *)message
{
    return [self errorWithCode:code
                      userInfo:@{
                          SKYErrorMessageKey : [message copy],
                          SKYErrorNameKey : SKYErrorNameWithCode(code),
                      }];
}

- (NSError *)errorWithCode:(SKYErrorCode)code userInfo:(NSDictionary *)userInfoToAdd
{
    NSMutableDictionary *finalUserInfo = [_defaultUserInfo mutableCopy];
    if (userInfoToAdd) {
        [finalUserInfo addEntriesFromDictionary:userInfoToAdd];
    }

    finalUserInfo[NSLocalizedDescriptionKey] = SKYErrorLocalizedDescriptionWithCode(code);
    finalUserInfo[SKYErrorNameKey] = SKYErrorNameWithCode(code);
    return
        [NSError errorWithDomain:SKYOperationErrorDomain code:code userInfo:[finalUserInfo copy]];
}

- (NSError *)errorWithResponseDictionary:(NSDictionary *)dict
{
    NSMutableDictionary *userInfo = [dict[@"info"] mutableCopy];
    if (!userInfo) {
        userInfo = [NSMutableDictionary dictionary];
    }

    NSInteger code = SKYErrorUnknownError;
    if ([dict[@"code"] isKindOfClass:[NSNumber class]]) {
        code = [dict[@"code"] integerValue];
    }

    if ([dict[@"name"] isKindOfClass:[NSString class]]) {
        userInfo[SKYErrorNameKey] = [dict[@"name"] copy];
    }

    if ([dict[@"message"] isKindOfClass:[NSString class]]) {
        userInfo[SKYErrorMessageKey] = [dict[@"message"] copy];
    }

    return [self errorWithCode:code userInfo:userInfo];
}

- (NSError *)partialErrorWithPerItemDictionary:(NSDictionary *)perItemErrors
{
    return [self errorWithCode:SKYErrorPartialOperationFailure
                      userInfo:@{
                          SKYErrorNameKey : SKYErrorNameWithCode(SKYErrorPartialOperationFailure),
                          SKYPartialErrorsByItemIDKey : [perItemErrors copy],
                      }];
}

@end
