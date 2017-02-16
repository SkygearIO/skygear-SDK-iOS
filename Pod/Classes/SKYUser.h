//
//  SKYUser.h
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

#import "SKYRecord.h"
#import "SKYRole.h"

@class SKYQueryCursor;
@class SKYQueryOperation;

/// Undocumented
@interface SKYUser : NSObject <NSCoding>

/// Undocumented
- (instancetype)init NS_UNAVAILABLE;
/// Undocumented
- (instancetype)initWithUserID:(NSString *)userID;

/// Undocumented
- (void)addRole:(SKYRole *)aRole;
/// Undocumented
- (void)removeRole:(SKYRole *)aRole;
/// Undocumented
- (BOOL)hasRole:(SKYRole *)aRole;

/// Undocumented
+ (instancetype)userWithUserID:(NSString *)userID;
/// Undocumented
+ (instancetype)userWithResponse:(NSDictionary *)userID __deprecated;

/// Undocumented
@property (nonatomic, copy) NSString *username;
/// Undocumented
@property (nonatomic, copy) NSString *email;
/// Undocumented
@property (nonatomic, copy) NSDate *lastLoginAt;
/// Undocumented
@property (nonatomic, copy) NSDate *lastSeenAt;
/// Undocumented
@property (nonatomic, copy) NSDictionary *authData;
/// Undocumented
@property (nonatomic, readonly, copy) NSArray<SKYRole *> *roles;
/// Undocumented
@property (nonatomic, readonly, assign) BOOL isNew;

/// Undocumented
@property (nonatomic, readonly, copy) NSString *userID;

@end
