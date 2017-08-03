//
//  SKYLoginUserOperation.h
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

#import "SKYOperation.h"

#import "SKYAccessToken.h"

NS_ASSUME_NONNULL_BEGIN

/// Undocumented
@interface SKYLoginUserOperation : SKYOperation

/// Undocumented
@property (nonatomic, readonly, copy) NSDictionary *_Nullable authData;
/// Undocumented
@property (nonatomic, readonly, copy) NSString *_Nullable password;
/// Undocumented
@property (nonatomic, readonly, copy) NSString *_Nullable provider;
/// Undocumented
@property (nonatomic, readonly, copy) NSDictionary *_Nullable providerAuthData;

/// Undocumented
@property (nonatomic, copy) void (^_Nullable loginCompletionBlock)
    (SKYRecord *_Nullable user, SKYAccessToken *_Nullable accessToken, NSError *_Nullable error);

/**
 Creates and returns an instance of operation for logging in a user with auth data and password.
 */
+ (instancetype)operationWithAuthData:(NSDictionary *)authData password:(NSString *)password;

/**
 Creates and returns an instance of operation for logging in a user with provider and its auth data.
 */
+ (instancetype)operationWithProvider:(NSString *)provider
                     providerAuthData:(NSDictionary *)providerAuthData;

@end

NS_ASSUME_NONNULL_END
