//
//  SKYErrorCreator.h
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

#import "SKYError.h"
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// Undocumented
@interface SKYErrorCreator : NSObject

/// Undocumented
@property (nonatomic, readwrite, copy) NSString *errorDomain;
/// Undocumented
@property (nonatomic, readonly) NSDictionary *defaultUserInfo;

/// Undocumented
- (instancetype)initWithDefaultErrorDomain:(NSString *)errorDomain NS_DESIGNATED_INITIALIZER;

/// Undocumented
- (void)setDefaultUserInfoObject:(id)obj forKey:(NSString *)key;

/// Undocumented
- (NSError *)errorWithCode:(SKYErrorCode)code;
/// Undocumented
- (NSError *)errorWithCode:(SKYErrorCode)code message:(NSString *)message;
/// Undocumented
- (NSError *)errorWithCode:(SKYErrorCode)code userInfo:(NSDictionary *_Nullable)userInfoToAdd;
/// Undocumented
- (NSError *)errorWithResponseDictionary:(NSDictionary *)dictionary;
/// Undocumented
- (NSError *)partialErrorWithPerItemDictionary:(NSDictionary *)perItemErrors;

@end

NS_ASSUME_NONNULL_END
