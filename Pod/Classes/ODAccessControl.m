//
//  ODAccessControl.m
//  Pods
//
//  Created by Kenji Pa on 9/6/15.
//
//

#import "ODAccessControl.h"

#import "ODAccessControl_Private.h"
#import "ODAccessControlEntry.h"

@implementation ODAccessControl

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

- (void)addEntry:(ODAccessControlEntry *)entry
{
    self.public = NO;
    [self.entries addObject:entry];
}

- (void)removeEntry:(ODAccessControlEntry *)entry
{
    [self.entries removeObject:entry];
}

- (void)addReadAccessForUser:(ODUser *)user
{
    [self addReadAccessForUserID:user.recordID];
}

- (void)addReadAccessForUserID:(ODUserRecordID *)userID
{
    [self addEntry:[ODAccessControlEntry readEntryForUserID:userID]];
}

- (void)addReadAccessForRelation:(ODRelation *)relation
{
    [self addEntry:[ODAccessControlEntry readEntryForRelation:relation]];
}

- (void)addWriteAccessForUser:(ODUser *)user
{
    [self addWriteAccessForUserID:user.recordID];
}

- (void)addWriteAccessForUserID:(ODUserRecordID *)userID
{
    [self addEntry:[ODAccessControlEntry writeEntryForUserID:userID]];
}

- (void)addWriteAccessForRelation:(ODRelation *)relation
{
    [self addEntry:[ODAccessControlEntry writeEntryForRelation:relation]];
}

- (void)removeReadAccessForUser:(ODUser *)user
{
    [self removeReadAccessForUserID:user.recordID];
}

- (void)removeReadAccessForUserID:(ODUserRecordID *)userID
{
    [self removeEntry:[ODAccessControlEntry readEntryForUserID:userID]];
}

- (void)removeReadAccessForRelation:(ODRelation *)relation
{
    [self removeEntry:[ODAccessControlEntry readEntryForRelation:relation]];
}

- (void)removeWriteAccessForUser:(ODUser *)user
{
    [self removeWriteAccessForUserID:user.recordID];
}

- (void)removeWriteAccessForUserID:(ODUserRecordID *)userID
{
    [self removeEntry:[ODAccessControlEntry writeEntryForUserID:userID]];
}

- (void)removeWriteAccessForRelation:(ODRelation *)relation
{
    [self removeEntry:[ODAccessControlEntry writeEntryForRelation:relation]];
}

@end
