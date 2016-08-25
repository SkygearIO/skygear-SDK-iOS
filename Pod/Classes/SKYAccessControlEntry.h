//
//  SKYAccessControlEntry.h
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
#import "SKYRole.h"
#import "SKYUser.h"

typedef enum : NSUInteger {
    SKYAccessControlEntryLevelRead = 0,
    SKYAccessControlEntryLevelWrite = 1,
} SKYAccessControlEntryLevel;

typedef enum : NSUInteger {
    SKYAccessControlEntryTypeRelation = 0,
    SKYAccessControlEntryTypeDirect = 1,
    SKYAccessControlEntryTypeRole = 2,
    SKYAccessControlEntryTypePublic = 3
} SKYAccessControlEntryType;

NSString *NSStringFromAccessControlEntryLevel(SKYAccessControlEntryLevel);

// NOTE(limouren): this class is consider an implementation details of SKYAccessControl
@interface SKYAccessControlEntry : NSObject <NSCoding>

+ (instancetype)readEntryForUser:(SKYUser *)user;
+ (instancetype)readEntryForUserID:(NSString *)user;
+ (instancetype)readEntryForRelation:(SKYRelation *)relation;
+ (instancetype)readEntryForRole:(SKYRole *)role;
+ (instancetype)readEntryForPublic;

+ (instancetype)writeEntryForUser:(SKYUser *)user;
+ (instancetype)writeEntryForUserID:(NSString *)user;
+ (instancetype)writeEntryForRelation:(SKYRelation *)relation;
+ (instancetype)writeEntryForRole:(SKYRole *)role;
+ (instancetype)writeEntryForPublic;

- (instancetype)init NS_UNAVAILABLE;
// avoid the following initializers, it is here because of deserializer
- (instancetype)initWithAccessLevel:(SKYAccessControlEntryLevel)accessLevel
                             userID:(NSString *)userID NS_DESIGNATED_INITIALIZER;
- (instancetype)initWithAccessLevel:(SKYAccessControlEntryLevel)accessLevel
                           relation:(SKYRelation *)relation NS_DESIGNATED_INITIALIZER;
- (instancetype)initWithAccessLevel:(SKYAccessControlEntryLevel)accessLevel
                               role:(SKYRole *)role NS_DESIGNATED_INITIALIZER;
- (instancetype)initWithPublicAccessLevel:(SKYAccessControlEntryLevel)accessLevel
    NS_DESIGNATED_INITIALIZER;

@property (nonatomic, readonly, assign) SKYAccessControlEntryType entryType;
@property (nonatomic, readonly, assign) SKYAccessControlEntryLevel accessLevel;
@property (nonatomic, readonly) SKYRelation *relation;
@property (nonatomic, readonly) SKYRole *role;
@property (nonatomic, copy, readonly) NSString *userID;

@end
