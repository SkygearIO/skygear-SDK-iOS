//
//  SKYSetDisableUserOperation.h
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
//

#import "SKYOperation.h"

NS_ASSUME_NONNULL_BEGIN

@class SKYRecord;

/**
 *  SKYSetDisableUserOperation is an operation for calling the API to disable a user account.
 */
@interface SKYSetDisableUserOperation : SKYOperation

/**
 *  User ID of user to disable.
 */
@property (nonatomic, copy) NSString *userID;

/**
 *  Sets or returns whether the user is disabled.
 */
@property (nonatomic, assign) BOOL disabled;

/**
 *  Message to be shown to user.
 *
 *  This message can be shown to the use to explain why the user account is disabled.
 */
@property (nonatomic, copy, nullable) NSString *message;

/**
 *  Date and time when the user account is automatically enabled.
 */
@property (nonatomic, copy, nonnull) NSDate *expiry;

/**
 *  Block to be called when the operation completes.
 */
@property (nonatomic, copy) void (^_Nullable setCompletionBlock)
    (NSString *userID, NSError *_Nullable error);

/**
 *  Returns an instance of operation to disable a user account.
 */
+ (instancetype)disableOperationWithUserID:(NSString *)userID
                                   message:(NSString *_Nullable)message
                                    expiry:(NSDate *_Nullable)expiry;

/**
 *  Returns an instance of operation to enable a user account.
 */
+ (instancetype)enableOperationWithUserID:(NSString *)userID;

- (instancetype)init NS_UNAVAILABLE;

/**
 *  Creates an instance of operation.
 */
- (instancetype)initWithUserID:(NSString *)userID
                      disabled:(BOOL)disabled
                       message:(NSString *_Nullable)message
                        expiry:(NSDate *_Nullable)expiry NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
