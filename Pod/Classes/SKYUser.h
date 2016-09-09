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

@interface SKYUser : NSObject

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithUserID:(NSString *)userID;

- (void)addRole:(SKYRole *)aRole;
- (void)removeRole:(SKYRole *)aRole;
- (BOOL)hasRole:(SKYRole *)aRole;

+ (instancetype)userWithUserID:(NSString *)userID;
+ (instancetype)userWithResponse:(NSDictionary *)userID;

@property (nonatomic, copy) NSString *username;
@property (nonatomic, copy) NSString *email;
@property (nonatomic, copy) NSDate *lastLoginAt;
@property (nonatomic, copy) NSDate *lastSeenAt;
@property (nonatomic, copy) NSDictionary *authData;
@property (nonatomic, strong) NSArray<SKYRole *> *roles;
@property (nonatomic, readonly, assign) BOOL isNew;

@property (nonatomic, readonly, copy) NSString *userID;

@end
