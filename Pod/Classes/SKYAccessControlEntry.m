//
//  SKYAccessControlEntry.m
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

#import "SKYAccessControlEntry.h"

NSString *NSStringFromAccessControlEntryLevel(SKYAccessControlEntryLevel level)
{
    switch (level) {
        case SKYAccessControlEntryLevelRead:
            return @"read";
        case SKYAccessControlEntryLevelWrite:
            return @"write";
        default:
            @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                           reason:@"Unrecgonized access control entry level"
                                         userInfo:@{
                                             @"SKYAccessControlEntryLevel" : @(level)
                                         }];
    }
}

@implementation SKYAccessControlEntry

- (BOOL)isEqualToAccessControlEntry:(SKYAccessControlEntry *)entry
{
    if (!entry) {
        return NO;
    }

    if (self.entryType != entry.entryType || self.accessLevel != entry.accessLevel) {
        return NO;
    }

    if (self.entryType == SKYAccessControlEntryTypePublic) {
        return YES;
    }

    if (self.relation != nil && entry.relation != nil) {
        return [self.relation isEqualToRelation:entry.relation];
    }

    if (self.role != nil && entry.role != nil) {
        return [self.role isEqual:entry.role];
    }

    if (self.userID != nil && entry.userID != nil) {
        return [self.userID isEqualToString:entry.userID];
    }

    return NO;
}

- (BOOL)isEqual:(id)object
{
    if (self == object) {
        return YES;
    }

    if (![object isKindOfClass:SKYAccessControlEntry.class]) {
        return NO;
    }

    return [self isEqualToAccessControlEntry:object];
}

- (NSUInteger)hash
{
    return (self.entryType << 1 + self.accessLevel) ^ self.relation.hash ^ self.userID.hash;
}

- (instancetype)initWithAccessLevel:(SKYAccessControlEntryLevel)accessLevel
                             userID:(NSString *)userID
{
    self = [super init];
    if (self) {
        _entryType = SKYAccessControlEntryTypeDirect;
        _accessLevel = accessLevel;
        _relation = nil;
        _role = nil;
        _userID = [userID copy];
    }
    return self;
}

- (instancetype)initWithAccessLevel:(SKYAccessControlEntryLevel)accessLevel
                           relation:(SKYRelation *)relation
{
    self = [super init];
    if (self) {
        _entryType = SKYAccessControlEntryTypeRelation;
        _accessLevel = accessLevel;
        _relation = relation;
        _role = nil;
        _userID = nil;
    }
    return self;
}

- (instancetype)initWithAccessLevel:(SKYAccessControlEntryLevel)accessLevel role:(SKYRole *)role
{
    self = [super init];
    if (self) {
        _entryType = SKYAccessControlEntryTypeRole;
        _accessLevel = accessLevel;
        _relation = nil;
        _role = role;
        _userID = nil;
    }
    return self;
}

- (instancetype)initWithPublicAccessLevel:(SKYAccessControlEntryLevel)accessLevel
{
    self = [super init];
    if (self) {
        _entryType = SKYAccessControlEntryTypePublic;
        _accessLevel = accessLevel;
        _relation = nil;
        _role = nil;
        _userID = nil;
    }
    return self;
}

+ (instancetype)readEntryForUser:(SKYUser *)user
{
    return [self readEntryForUserID:user.userID];
}

+ (instancetype)readEntryForUserID:(NSString *)userID
{
    return [[self alloc] initWithAccessLevel:SKYAccessControlEntryLevelRead userID:userID];
}

+ (instancetype)readEntryForRelation:(SKYRelation *)relation
{
    return [[self alloc] initWithAccessLevel:SKYAccessControlEntryLevelRead relation:relation];
}

+ (instancetype)readEntryForRole:(SKYRole *)role
{
    return [[self alloc] initWithAccessLevel:SKYAccessControlEntryLevelRead role:role];
}

+ (instancetype)readEntryForPublic
{
    return [[self alloc] initWithPublicAccessLevel:SKYAccessControlEntryLevelRead];
}

+ (instancetype)writeEntryForUser:(SKYUser *)user
{
    return [self writeEntryForUserID:user.userID];
}

+ (instancetype)writeEntryForUserID:(NSString *)userID
{
    return [[self alloc] initWithAccessLevel:SKYAccessControlEntryLevelWrite userID:userID];
}

+ (instancetype)writeEntryForRelation:(SKYRelation *)relation
{
    return [[self alloc] initWithAccessLevel:SKYAccessControlEntryLevelWrite relation:relation];
}

+ (instancetype)writeEntryForRole:(SKYRole *)role
{
    return [[self alloc] initWithAccessLevel:SKYAccessControlEntryLevelWrite role:role];
}

+ (instancetype)writeEntryForPublic
{
    return [[self alloc] initWithPublicAccessLevel:SKYAccessControlEntryLevelWrite];
}

#pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeInteger:self.entryType forKey:@"entryType"];
    [aCoder encodeInteger:self.accessLevel forKey:@"accessLevel"];
    [aCoder encodeObject:self.relation forKey:@"relation"];
    [aCoder encodeObject:self.role forKey:@"role"];
    [aCoder encodeObject:self.userID forKey:@"userID"];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    SKYAccessControlEntryType entryType = [aDecoder decodeIntegerForKey:@"entryType"];
    SKYAccessControlEntryLevel accessLevel = [aDecoder decodeIntegerForKey:@"accessLevel"];
    switch (entryType) {
        case SKYAccessControlEntryTypeRelation:
            return [self initWithAccessLevel:accessLevel
                                    relation:[aDecoder decodeObjectOfClass:[SKYRelation class]
                                                                    forKey:@"relation"]];
        case SKYAccessControlEntryTypeDirect:
            return [self initWithAccessLevel:accessLevel
                                      userID:[aDecoder decodeObjectOfClass:[NSString class]
                                                                    forKey:@"userID"]];
        case SKYAccessControlEntryTypeRole:
            return [self
                initWithAccessLevel:accessLevel
                               role:[aDecoder decodeObjectOfClass:[SKYRole class] forKey:@"role"]];
        case SKYAccessControlEntryTypePublic:
            return [self initWithPublicAccessLevel:accessLevel];
    }
    return nil;
}

@end
