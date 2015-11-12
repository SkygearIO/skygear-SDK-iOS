//
//  SKYAccessControlEntry.m
//  Pods
//
//  Created by Kenji Pa on 9/6/15.
//
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
             [self.userID isEqualToUserRecordID:entry.userID]));
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
                             userID:(SKYUserRecordID *)userID
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

+ (instancetype)readEntryForUserID:(SKYUserRecordID *)userID
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

+ (instancetype)writeEntryForUserID:(SKYUserRecordID *)userID
{
    return [[self alloc] initWithAccessLevel:SKYAccessControlEntryLevelWrite userID:userID];
}

+ (instancetype)writeEntryForRelation:(SKYRelation *)relation
{
    return [[self alloc] initWithAccessLevel:SKYAccessControlEntryLevelWrite relation:relation];
}

@end
