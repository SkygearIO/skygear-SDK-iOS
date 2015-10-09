//
//  SKYAccessControl.m
//  Pods
//
//  Created by Kenji Pa on 9/6/15.
//
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
                                  objects:(id __unsafe_unretained [])buffer
                                    count:(NSUInteger)len;
{
    return [self.entries countByEnumeratingWithState:state
                                             objects:buffer
                                               count:len];
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
