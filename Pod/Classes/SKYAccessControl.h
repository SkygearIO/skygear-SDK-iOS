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

@class SKYUser;
@class SKYRole;

@interface SKYAccessControl : NSObject <NSCoding, NSCopying>

- (instancetype)init NS_UNAVAILABLE;

#pragma mark - set no access
- (void)setNoAccessForUser:(SKYUser *)user;
- (void)setNoAccessForUserID:(NSString *)userID;
- (void)setNoAccessForRelation:(SKYRelation *)relation;
- (void)setNoAccessForRole:(SKYRole *)role;
- (void)setNoAccessForPublic;

#pragma mark - set read only
- (void)setReadOnlyForUser:(SKYUser *)user;
- (void)setReadOnlyForUserID:(NSString *)userID;
- (void)setReadOnlyForRelation:(SKYRelation *)relation;
- (void)setReadOnlyForRole:(SKYRole *)role;
- (void)setReadOnlyForPublic;

#pragma mark - set read write access
- (void)setReadWriteAccessForUser:(SKYUser *)user;
- (void)setReadWriteAccessForUserID:(NSString *)userID;
- (void)setReadWriteAccessForRelation:(SKYRelation *)relation;
- (void)setReadWriteAccessForRole:(SKYRole *)role;
- (void)setReadWriteAccessForPublic;

#pragma mark - has read access checking
- (BOOL)hasReadAccessForUser:(SKYUser *)user;
- (BOOL)hasReadAccessForUserID:(NSString *)userID;
- (BOOL)hasReadAccessForRelation:(SKYRelation *)relation;
- (BOOL)hasReadAccessForRole:(SKYRole *)role;
- (BOOL)hasReadAccessForPublic;

#pragma mark - has write access checking
- (BOOL)hasWriteAccessForUser:(SKYUser *)user;
- (BOOL)hasWriteAccessForUserID:(NSString *)userID;
- (BOOL)hasWriteAccessForRelation:(SKYRelation *)relation;
- (BOOL)hasWriteAccessForRole:(SKYRole *)role;
- (BOOL)hasWriteAccessForPublic;

@end
