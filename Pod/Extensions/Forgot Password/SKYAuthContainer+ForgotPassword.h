//
//  SKYAuthContainer+ForgotPassword.h
//  SKYKit
//
//  Copyright 2017 Oursky Ltd.
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

#import "SKYKit.h"

NS_ASSUME_NONNULL_BEGIN

@interface SKYAuthContainer (ForgotPassword)

- (void)forgotPasswordWithEmail:(NSString *)emailAddress
              completionHandler:
                  (void (^_Nullable)(NSDictionary *_Nullable, NSError *_Nullable))completionHandler;

- (void)resetPasswordWithUserID:(NSString *)userID
                           code:(NSString *)code
                       expireAt:(long)expireAt
                       password:(NSString *)password
              completionHandler:
                  (void (^_Nullable)(NSDictionary *_Nullable, NSError *_Nullable))completionHandler;

/**
 *  Request user data verification of the specified record key.
 *
 *  @param recordKey       The record key to be verified
 *  @param completionBlock Completion Block
 */
- (void)requestVerification:(NSString *)recordKey
                 completion:(void (^_Nullable)(NSError *_Nullable error))completionBlock;

/**
 *  Mark a user account as verified by specifying a verification code.
 *
 *  @param code            Verification code
 *  @param completionBlock Completion Block
 */
- (void)verifyUserWithCode:(NSString *)code
                completion:(SKYContainerUserOperationActionCompletion _Nullable)completionBlock;

@end

NS_ASSUME_NONNULL_END
