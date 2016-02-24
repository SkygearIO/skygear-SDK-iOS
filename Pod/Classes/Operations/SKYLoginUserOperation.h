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

@interface SKYLoginUserOperation : SKYOperation

@property (nonatomic, readonly, copy) NSString *username;
@property (nonatomic, readonly, copy) NSString *email;
@property (nonatomic, readonly, copy) NSString *password;
@property (nonatomic, readonly, copy) NSString *provider;
@property (nonatomic, readonly, copy) NSDictionary *authenticationData;

@property (nonatomic, copy) void (^loginCompletionBlock)
    (SKYUser *user, SKYAccessToken *accessToken, NSError *error);

/**
 Creates and returns an instance of operation for logging in a user with username and password.
 */
+ (instancetype)operationWithUsername:(NSString *)username password:(NSString *)password;

/**
 Creates and returns an instance of operation for logging in a user with email and password.
 */
+ (instancetype)operationWithEmail:(NSString *)email password:(NSString *)password;

/**
 Creates and returns an instance of operation for logging in a user with provider and auth data.
 */
+ (instancetype)operationWithProvider:(NSString *)provider
                   authenticationData:(NSDictionary *)authData;

@end
