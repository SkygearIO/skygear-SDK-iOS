//
//  SKYAccessControl.m
//  SkyKit
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

- (void)addReadAccessForUser:(SKYUser *)user
{
    [self addReadAccessForUserID:user.recordID];
}

- (void)addReadAccessForUserID:(SKYUserRecordID *)userID
{
    [self addEntry:[SKYAccessControlEntry readEntryForUserID:userID]];
}

- (void)addReadAccessForRelation:(SKYRelation *)relation
{
    [self addEntry:[SKYAccessControlEntry readEntryForRelation:relation]];
}

- (void)addWriteAccessForUser:(SKYUser *)user
{
    [self addWriteAccessForUserID:user.recordID];
}

- (void)addWriteAccessForUserID:(SKYUserRecordID *)userID
{
    [self addEntry:[SKYAccessControlEntry writeEntryForUserID:userID]];
}

- (void)addWriteAccessForRelation:(SKYRelation *)relation
{
    [self addEntry:[SKYAccessControlEntry writeEntryForRelation:relation]];
}

- (void)removeReadAccessForUser:(SKYUser *)user
{
    [self removeReadAccessForUserID:user.recordID];
}

- (void)removeReadAccessForUserID:(SKYUserRecordID *)userID
{
    [self removeEntry:[SKYAccessControlEntry readEntryForUserID:userID]];
}

- (void)removeReadAccessForRelation:(SKYRelation *)relation
{
    [self removeEntry:[SKYAccessControlEntry readEntryForRelation:relation]];
}

- (void)removeWriteAccessForUser:(SKYUser *)user
{
    [self removeWriteAccessForUserID:user.recordID];
}

- (void)removeWriteAccessForUserID:(SKYUserRecordID *)userID
{
    [self removeEntry:[SKYAccessControlEntry writeEntryForUserID:userID]];
}

- (void)removeWriteAccessForRelation:(SKYRelation *)relation
{
    [self removeEntry:[SKYAccessControlEntry writeEntryForRelation:relation]];
}

@end
