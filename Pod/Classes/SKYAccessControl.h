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

@interface SKYAccessControl : NSObject <NSFastEnumeration>

- (instancetype)init NS_UNAVAILABLE;

- (void)__deprecated setPublicReadWriteAccess;

#pragma mark - add read access
- (void)addReadAccessForUser:(SKYUser *)user;
- (void)addReadAccessForUserID:(NSString *)userID;
- (void)addReadAccessForRelation:(SKYRelation *)relation;
- (void)addReadAccessForRole:(SKYRole *)role;
- (void)addReadAccessForPublic;

#pragma mark - add write access
- (void)addWriteAccessForUser:(SKYUser *)user;
- (void)addWriteAccessForUserID:(NSString *)userID;
- (void)addWriteAccessForRelation:(SKYRelation *)relation;
- (void)addWriteAccessForRole:(SKYRole *)role;
- (void)addWriteAccessForPublic;

#pragma mark - remove read access
- (void)removeReadAccessForUser:(SKYUser *)user;
- (void)removeReadAccessForUserID:(NSString *)userID;
- (void)removeReadAccessForRelation:(SKYRelation *)relation;
- (void)removeReadAccessForRole:(SKYRole *)role;
- (void)removeReadAccessForPublic;

#pragma mark - remove write access
- (void)removeWriteAccessForUser:(SKYUser *)user;
- (void)removeWriteAccessForUserID:(NSString *)userID;
- (void)removeWriteAccessForRelation:(SKYRelation *)relation;
- (void)removeWriteAccessForRole:(SKYRole *)role;
- (void)removeWriteAccessForPublic;

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

@property (nonatomic, readonly) __deprecated BOOL public;

@end
