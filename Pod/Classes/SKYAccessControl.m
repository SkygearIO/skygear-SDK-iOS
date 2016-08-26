//
//  SKYAccessControl.m
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

#import "SKYAccessControl.h"

#import "SKYAccessControlDeserializer.h"
#import "SKYAccessControlEntry.h"
#import "SKYAccessControlSerializer.h"
#import "SKYAccessControl_Private.h"

@implementation SKYAccessControl

+ (instancetype)publicReadableAccessControl
{
    return [[self alloc] initWithPublicReadableAccessControl];
}

+ (instancetype)accessControlWithEntries:(NSArray<SKYAccessControlEntry *> *)entries
{
    return [[self alloc] initWithEntries:entries];
}

+ (instancetype)defaultAccessControl
{
    static SKYAccessControlDeserializer *deserializer;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        deserializer = [SKYAccessControlDeserializer deserializer];
    });

    NSArray *aclData =
        [[NSUserDefaults standardUserDefaults] objectForKey:@"SKYAccessControlDefault"];

    if (aclData) {
        return [deserializer accessControlWithArray:aclData];
    } else {
        return [SKYAccessControl publicReadableAccessControl];
    }
}

+ (void)setDefaultAccessControl:(SKYAccessControl *)defaultAccessControl
{
    static SKYAccessControlSerializer *serializer;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        serializer = [SKYAccessControlSerializer serializer];
    });

    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];

    if (!defaultAccessControl) {
        [userDefault removeObjectForKey:@"SKYAccessControlDefault"];
    } else {
        NSArray *aclData = [serializer arrayWithAccessControl:defaultAccessControl];
        [userDefault setObject:aclData forKey:@"SKYAccessControlDefault"];
    }

    [userDefault synchronize];
}

- (instancetype)initWithPublicReadableAccessControl
{
    return [self initWithEntries:@[ [SKYAccessControlEntry readEntryForPublic] ]];
}

- (instancetype)initWithEntries:(NSArray<SKYAccessControlEntry *> *)entries
{
    self = [super init];
    if (self) {
        self.entries = [NSMutableOrderedSet orderedSetWithArray:entries];
    }
    return self;
}

- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state
                                  objects:(id __unsafe_unretained[])buffer
                                    count:(NSUInteger)len;
{
    return [self.entries countByEnumeratingWithState:state objects:buffer count:len];
}

- (void)addEntry:(SKYAccessControlEntry *)entry
{
    [self.entries addObject:entry];
}

- (void)removeEntry:(SKYAccessControlEntry *)entry
{
    [self.entries removeObject:entry];
}

- (BOOL)hasAccessForEntry:(SKYAccessControlEntry *)entry
{
    return [self.entries indexOfObject:entry] != NSNotFound;
}

#pragma mark - set no access
- (void)setNoAccessForUser:(SKYUser *)user
{
    [self setNoAccessForUserID:user.userID];
}

- (void)setNoAccessForUserID:(NSString *)userID
{
    [self.entries
        filterUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(SKYAccessControlEntry *perEntry,
                                                                   NSDictionary *bindings) {
            return perEntry.entryType != SKYAccessControlEntryTypeDirect ||
                   perEntry.userID != userID;
        }]];
}

- (void)setNoAccessForRelation:(SKYRelation *)relation
{
    [self.entries
        filterUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(SKYAccessControlEntry *perEntry,
                                                                   NSDictionary *bindings) {
            return perEntry.entryType != SKYAccessControlEntryTypeRelation ||
                   perEntry.relation != relation;
        }]];
}

- (void)setNoAccessForRole:(SKYRole *)role
{
    [self.entries
        filterUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(SKYAccessControlEntry *perEntry,
                                                                   NSDictionary *bindings) {
            return perEntry.entryType != SKYAccessControlEntryTypeRole || perEntry.role != role;
        }]];
}

- (void)setNoAccessForPublic
{
    [self.entries
        filterUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(SKYAccessControlEntry *perEntry,
                                                                   NSDictionary *bindings) {
            return perEntry.entryType != SKYAccessControlEntryTypePublic;
        }]];
}

#pragma mark - set read only
- (void)setReadOnlyForUser:(SKYUser *)user
{
    [self setReadOnlyForUserID:user.userID];
}

- (void)setReadOnlyForUserID:(NSString *)userID
{
    [self setNoAccessForUserID:userID];
    [self addEntry:[SKYAccessControlEntry readEntryForUserID:userID]];
}

- (void)setReadOnlyForRelation:(SKYRelation *)relation
{
    [self setNoAccessForRelation:relation];
    [self addEntry:[SKYAccessControlEntry readEntryForRelation:relation]];
}

- (void)setReadOnlyForRole:(SKYRole *)role
{
    [self setNoAccessForRole:role];
    [self addEntry:[SKYAccessControlEntry readEntryForRole:role]];
}

- (void)setReadOnlyForPublic
{
    [self setNoAccessForPublic];
    [self addEntry:[SKYAccessControlEntry readEntryForPublic]];
}

#pragma mark - set read write access
- (void)setReadWriteAccessForUser:(SKYUser *)user
{
    [self setReadWriteAccessForUserID:user.userID];
}

- (void)setReadWriteAccessForUserID:(NSString *)userID
{
    [self setNoAccessForUserID:userID];
    [self addEntry:[SKYAccessControlEntry writeEntryForUserID:userID]];
}

- (void)setReadWriteAccessForRelation:(SKYRelation *)relation
{
    [self setNoAccessForRelation:relation];
    [self addEntry:[SKYAccessControlEntry writeEntryForRelation:relation]];
}

- (void)setReadWriteAccessForRole:(SKYRole *)role
{
    [self setNoAccessForRole:role];
    [self addEntry:[SKYAccessControlEntry writeEntryForRole:role]];
}

- (void)setReadWriteAccessForPublic
{
    [self setNoAccessForPublic];
    [self addEntry:[SKYAccessControlEntry writeEntryForPublic]];
}

#pragma mark - has read access checking
- (BOOL)hasReadAccessForUser:(SKYUser *)user
{
    return [self hasReadAccessForUserID:user.userID];
}

- (BOOL)hasReadAccessForUserID:(NSString *)userID
{
    return [self hasAccessForEntry:[SKYAccessControlEntry readEntryForUserID:userID]] ||
           [self hasAccessForEntry:[SKYAccessControlEntry writeEntryForUserID:userID]] ||
           [self hasReadAccessForPublic];
}

- (BOOL)hasReadAccessForRelation:(SKYRelation *)relation
{
    return [self hasAccessForEntry:[SKYAccessControlEntry readEntryForRelation:relation]] ||
           [self hasAccessForEntry:[SKYAccessControlEntry writeEntryForRelation:relation]] ||
           [self hasReadAccessForPublic];
}

- (BOOL)hasReadAccessForRole:(SKYRole *)role
{
    return [self hasAccessForEntry:[SKYAccessControlEntry readEntryForRole:role]] ||
           [self hasAccessForEntry:[SKYAccessControlEntry writeEntryForRole:role]] ||
           [self hasReadAccessForPublic];
}

- (BOOL)hasReadAccessForPublic
{
    return [self hasAccessForEntry:[SKYAccessControlEntry readEntryForPublic]] ||
           [self hasAccessForEntry:[SKYAccessControlEntry writeEntryForPublic]];
}

#pragma mark - has write access checking
- (BOOL)hasWriteAccessForUser:(SKYUser *)user
{
    return [self hasWriteAccessForUserID:user.userID];
}

- (BOOL)hasWriteAccessForUserID:(NSString *)userID
{
    return [self hasAccessForEntry:[SKYAccessControlEntry writeEntryForUserID:userID]] ||
           [self hasWriteAccessForPublic];
}

- (BOOL)hasWriteAccessForRelation:(SKYRelation *)relation
{
    return [self hasAccessForEntry:[SKYAccessControlEntry writeEntryForRelation:relation]] ||
           [self hasWriteAccessForPublic];
}

- (BOOL)hasWriteAccessForRole:(SKYRole *)role
{
    return [self hasAccessForEntry:[SKYAccessControlEntry writeEntryForRole:role]] ||
           [self hasWriteAccessForPublic];
}

- (BOOL)hasWriteAccessForPublic
{
    return [self hasAccessForEntry:[SKYAccessControlEntry writeEntryForPublic]];
}

#pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:[self.entries array] forKey:@"entries"];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    return [self initWithEntries:[aDecoder decodeObjectForKey:@"entries"]];
}

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone
{
    return [[[self class] alloc] initWithEntries:[self.entries array]];
}

@end
