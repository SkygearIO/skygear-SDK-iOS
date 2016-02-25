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

#import "SKYAccessControl_Private.h"
#import "SKYAccessControlEntry.h"

@implementation SKYAccessControl

+ (instancetype)publicReadWriteAccessControl
{
    return [[self alloc] initForPublicReadWrite];
}

+ (instancetype)accessControlWithEntries:(NSArray *)entries
{
    return [[self alloc] initWithEntries:entries];
}

- (instancetype)initForPublicReadWrite
{
    self = [super init];
    if (self) {
        self.entries = [NSMutableOrderedSet orderedSet];
        self.public = YES;
    }
    return self;
}

- (instancetype)initWithEntries:(NSArray *)entries
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

- (void)setPublicReadWriteAccess
{
    self.public = YES;
    [self.entries removeAllObjects];
}

- (void)addEntry:(SKYAccessControlEntry *)entry
{
    self.public = NO;
    [self.entries addObject:entry];
}

- (void)removeEntry:(SKYAccessControlEntry *)entry
{
    [self.entries removeObject:entry];
}

- (BOOL)hasAccessForEntry:(SKYAccessControlEntry *)entry
{
    return self.public || [self.entries indexOfObject:entry] != NSNotFound;
}

#pragma mark - add read access
- (void)addReadAccessForUser:(SKYUser *)user
{
    [self addReadAccessForUserID:user.userID];
}

- (void)addReadAccessForUserID:(NSString *)userID
{
    [self addEntry:[SKYAccessControlEntry readEntryForUserID:userID]];
}

- (void)addReadAccessForRelation:(SKYRelation *)relation
{
    [self addEntry:[SKYAccessControlEntry readEntryForRelation:relation]];
}

- (void)addReadAccessForRole:(SKYRole *)role
{
    [self addEntry:[SKYAccessControlEntry readEntryForRole:role]];
}

#pragma mark - add write access
- (void)addWriteAccessForUser:(SKYUser *)user
{
    [self addWriteAccessForUserID:user.userID];
}

- (void)addWriteAccessForUserID:(NSString *)userID
{
    [self addEntry:[SKYAccessControlEntry writeEntryForUserID:userID]];
}

- (void)addWriteAccessForRelation:(SKYRelation *)relation
{
    [self addEntry:[SKYAccessControlEntry writeEntryForRelation:relation]];
}

- (void)addWriteAccessForRole:(SKYRole *)role
{
    [self addEntry:[SKYAccessControlEntry writeEntryForRole:role]];
}

#pragma mark - remove read access
- (void)removeReadAccessForUser:(SKYUser *)user
{
    [self removeReadAccessForUserID:user.userID];
}

- (void)removeReadAccessForUserID:(NSString *)userID
{
    [self removeEntry:[SKYAccessControlEntry readEntryForUserID:userID]];
}

- (void)removeReadAccessForRelation:(SKYRelation *)relation
{
    [self removeEntry:[SKYAccessControlEntry readEntryForRelation:relation]];
}

- (void)removeReadAccessForRole:(SKYRole *)role
{
    [self removeEntry:[SKYAccessControlEntry readEntryForRole:role]];
}

#pragma mark - remove write access
- (void)removeWriteAccessForUser:(SKYUser *)user
{
    [self removeWriteAccessForUserID:user.userID];
}

- (void)removeWriteAccessForUserID:(NSString *)userID
{
    [self removeEntry:[SKYAccessControlEntry writeEntryForUserID:userID]];
}

- (void)removeWriteAccessForRelation:(SKYRelation *)relation
{
    [self removeEntry:[SKYAccessControlEntry writeEntryForRelation:relation]];
}

- (void)removeWriteAccessForRole:(SKYRole *)role
{
    [self removeEntry:[SKYAccessControlEntry writeEntryForRole:role]];
}

#pragma mark - has read access checking
- (BOOL)hasReadAccessForUser:(SKYUser *)user
{
    return [self hasReadAccessForUserID:user.userID];
}

- (BOOL)hasReadAccessForUserID:(NSString *)userID
{
    return [self hasAccessForEntry:[SKYAccessControlEntry readEntryForUserID:userID]];
}

- (BOOL)hasReadAccessForRelation:(SKYRelation *)relation
{
    return [self hasAccessForEntry:[SKYAccessControlEntry readEntryForRelation:relation]];
}

- (BOOL)hasReadAccessForRole:(SKYRole *)role
{
    return [self hasAccessForEntry:[SKYAccessControlEntry readEntryForRole:role]];
}

#pragma mark - has write access checking
- (BOOL)hasWriteAccessForUser:(SKYUser *)user
{
    return [self hasWriteAccessForUserID:user.userID];
}

- (BOOL)hasWriteAccessForUserID:(NSString *)userID
{
    return [self hasAccessForEntry:[SKYAccessControlEntry writeEntryForUserID:userID]];
}

- (BOOL)hasWriteAccessForRelation:(SKYRelation *)relation
{
    return [self hasAccessForEntry:[SKYAccessControlEntry writeEntryForRelation:relation]];
}

- (BOOL)hasWriteAccessForRole:(SKYRole *)role
{
    return [self hasAccessForEntry:[SKYAccessControlEntry writeEntryForRole:role]];
}

@end
