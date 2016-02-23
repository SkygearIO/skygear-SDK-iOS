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

    return (self.entryType == entry.entryType && self.accessLevel == entry.accessLevel &&
            ((self.relation == nil && entry.relation == nil) ||
             [self.relation isEqualToRelation:entry.relation]) &&
            ((self.userID == nil && entry.userID == nil) ||
             [self.userID isEqualToString:entry.userID]));
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
    }
    return self;
}

+ (instancetype)readEntryForUser:(SKYUser *)user
{
    return [self readEntryForUserID:user.recordID];
}

+ (instancetype)readEntryForUserID:(NSString *)userID
{
    return [[self alloc] initWithAccessLevel:SKYAccessControlEntryLevelRead userID:userID];
}

+ (instancetype)readEntryForRelation:(SKYRelation *)relation
{
    return [[self alloc] initWithAccessLevel:SKYAccessControlEntryLevelRead relation:relation];
}

+ (instancetype)writeEntryForUser:(SKYUser *)user
{
    return [self writeEntryForUserID:user.recordID];
}

+ (instancetype)writeEntryForUserID:(NSString *)userID
{
    return [[self alloc] initWithAccessLevel:SKYAccessControlEntryLevelWrite userID:userID];
}

+ (instancetype)writeEntryForRelation:(SKYRelation *)relation
{
    return [[self alloc] initWithAccessLevel:SKYAccessControlEntryLevelWrite relation:relation];
}

@end
