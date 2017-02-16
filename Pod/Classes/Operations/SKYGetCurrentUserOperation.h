//
//  SKYGetCurrentUserOperation.h
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

@class SKYUser;
@class SKYAccessToken;

/**
 * <SKYGetCurrentUserOperation> is a <SKYOperation> for getting current user from server
 */
@interface SKYGetCurrentUserOperation : SKYOperation

/**
 *  Completiong Block of the Get Current User Operation
 */
@property (nonatomic, copy, nullable) void (^getCurrentUserCompletionBlock)
    (SKYUser *_Nullable user, SKYAccessToken *_Nullable accessToken, NSError *_Nullable error);

@end
