//
//  SKYLoginCustomTokenOperation.h
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

/// SKYLoginCustomTokenOperation is used to send a login with custom token request to the server.
@interface SKYLoginCustomTokenOperation : SKYOperation

/**
 Returns a custom token in the operation.
 */
@property (nonatomic, readonly, copy) NSString *customToken;

/**
 Gets or sets the block that is called when the login operation is completed.
 */
@property (nonatomic, copy) void (^_Nullable loginCompletionBlock)
    (SKYRecord *_Nullable user, SKYAccessToken *_Nullable accessToken, NSError *_Nullable error);

/**
 Creates a login with custom token operation with the specified custom token.

 @param customToken custom token for the login operation.
 */
+ (instancetype)operationWithCustomToken:(NSString *)customToken;

@end

NS_ASSUME_NONNULL_END
