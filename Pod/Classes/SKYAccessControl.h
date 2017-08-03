//
//  SKYAccessControl.h
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

#import <Foundation/Foundation.h>

#import "SKYRelation.h"

NS_ASSUME_NONNULL_BEGIN

@class SKYRecord;
@class SKYRole;

/// Undocumented
@interface SKYAccessControl : NSObject <NSCoding, NSCopying>

/// Undocumented
- (instancetype)init NS_UNAVAILABLE;

#pragma mark - set no access
/// Undocumented
- (void)setNoAccessForUser:(SKYRecord *)user;
/// Undocumented
- (void)setNoAccessForUserID:(NSString *)userID;
/// Undocumented
- (void)setNoAccessForRelation:(SKYRelation *)relation;
/// Undocumented
- (void)setNoAccessForRole:(SKYRole *)role;
/// Undocumented
- (void)setNoAccessForPublic;

#pragma mark - set read only
/// Undocumented
- (void)setReadOnlyForUser:(SKYRecord *)user;
/// Undocumented
- (void)setReadOnlyForUserID:(NSString *)userID;
/// Undocumented
- (void)setReadOnlyForRelation:(SKYRelation *)relation;
/// Undocumented
- (void)setReadOnlyForRole:(SKYRole *)role;
/// Undocumented
- (void)setReadOnlyForPublic;

#pragma mark - set read write access
/// Undocumented
- (void)setReadWriteAccessForUser:(SKYRecord *)user;
/// Undocumented
- (void)setReadWriteAccessForUserID:(NSString *)userID;
/// Undocumented
- (void)setReadWriteAccessForRelation:(SKYRelation *)relation;
/// Undocumented
- (void)setReadWriteAccessForRole:(SKYRole *)role;
/// Undocumented
- (void)setReadWriteAccessForPublic;

#pragma mark - has read access checking
/// Undocumented
- (BOOL)hasReadAccessForUser:(SKYRecord *)user;
/// Undocumented
- (BOOL)hasReadAccessForUserID:(NSString *)userID;
/// Undocumented
- (BOOL)hasReadAccessForRelation:(SKYRelation *)relation;
/// Undocumented
- (BOOL)hasReadAccessForRole:(SKYRole *)role;
/// Undocumented
- (BOOL)hasReadAccessForPublic;

#pragma mark - has write access checking
/// Undocumented
- (BOOL)hasWriteAccessForUser:(SKYRecord *)user;
/// Undocumented
- (BOOL)hasWriteAccessForUserID:(NSString *)userID;
/// Undocumented
- (BOOL)hasWriteAccessForRelation:(SKYRelation *)relation;
/// Undocumented
- (BOOL)hasWriteAccessForRole:(SKYRole *)role;
/// Undocumented
- (BOOL)hasWriteAccessForPublic;

@end

NS_ASSUME_NONNULL_END
