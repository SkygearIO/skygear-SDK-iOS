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

#import "SKYRecord.h"
#import "SKYRelation.h"
#import "SKYRole.h"

NS_ASSUME_NONNULL_BEGIN

/// Undocumented
typedef enum : NSUInteger {
    SKYAccessControlEntryLevelRead = 0,
    SKYAccessControlEntryLevelWrite = 1,
} SKYAccessControlEntryLevel;

/// Undocumented
typedef enum : NSUInteger {
    SKYAccessControlEntryTypeRelation = 0,
    SKYAccessControlEntryTypeDirect = 1,
    SKYAccessControlEntryTypeRole = 2,
    SKYAccessControlEntryTypePublic = 3
} SKYAccessControlEntryType;

NSString *NSStringFromAccessControlEntryLevel(SKYAccessControlEntryLevel);

// NOTE(limouren): this class is consider an implementation details of SKYAccessControl
/// Undocumented
@interface SKYAccessControlEntry : NSObject <NSCoding>

/// Undocumented
+ (instancetype)readEntryForUserID:(NSString *)user;
/// Undocumented
+ (instancetype)readEntryForRelation:(SKYRelation *)relation;
/// Undocumented
+ (instancetype)readEntryForRole:(SKYRole *)role;
/// Undocumented
+ (instancetype)readEntryForPublic;

/// Undocumented
+ (instancetype)writeEntryForUserID:(NSString *)user;
/// Undocumented
+ (instancetype)writeEntryForRelation:(SKYRelation *)relation;
/// Undocumented
+ (instancetype)writeEntryForRole:(SKYRole *)role;
/// Undocumented
+ (instancetype)writeEntryForPublic;

/// Undocumented
- (instancetype)init NS_UNAVAILABLE;
// avoid the following initializers, it is here because of deserializer
/// Undocumented
- (instancetype)initWithAccessLevel:(SKYAccessControlEntryLevel)accessLevel
                             userID:(NSString *)userID NS_DESIGNATED_INITIALIZER;
/// Undocumented
- (instancetype)initWithAccessLevel:(SKYAccessControlEntryLevel)accessLevel
                           relation:(SKYRelation *)relation NS_DESIGNATED_INITIALIZER;
/// Undocumented
- (instancetype)initWithAccessLevel:(SKYAccessControlEntryLevel)accessLevel
                               role:(SKYRole *)role NS_DESIGNATED_INITIALIZER;
/// Undocumented
- (instancetype)initWithPublicAccessLevel:(SKYAccessControlEntryLevel)accessLevel
    NS_DESIGNATED_INITIALIZER;

/// Undocumented
@property (nonatomic, readonly, assign) SKYAccessControlEntryType entryType;
/// Undocumented
@property (nonatomic, readonly, assign) SKYAccessControlEntryLevel accessLevel;
/// Undocumented
@property (nonatomic, readonly) SKYRelation *_Nullable relation;
/// Undocumented
@property (nonatomic, readonly) SKYRole *_Nullable role;
/// Undocumented
@property (nonatomic, copy, readonly) NSString *_Nullable userID;

@end

@interface SKYAccessControlEntry (UserRecord)

/// Undocumented
+ (instancetype)readEntryForUser:(SKYRecord *)user;
/// Undocumented
+ (instancetype)writeEntryForUser:(SKYRecord *)user;

@end

NS_ASSUME_NONNULL_END
