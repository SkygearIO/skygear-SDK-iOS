//
//  SKYDefineAdminRolesOperation.h
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

NS_ASSUME_NONNULL_BEGIN

@class SKYRole;

/// Undocumented
@interface SKYDefineAdminRolesOperation : SKYOperation

/// Undocumented
@property (nonatomic, readonly, strong) NSArray<SKYRole *> *roles;
/// Undocumented
@property (nonatomic, copy) void (^_Nullable defineAdminRolesCompletionBlock)
    (NSArray<SKYRole *> *_Nullable roles, NSError *_Nullable error);

/// Undocumented
+ (instancetype)operationWithRoles:(NSArray<SKYRole *> *)roles;

@end

NS_ASSUME_NONNULL_END
