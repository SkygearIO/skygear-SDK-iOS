//
//  ODAccessControlEntry.m
//  Pods
//
//  Created by Kenji Pa on 9/6/15.
//
//

#import "ODAccessControlEntry.h"

NSString * NSStringFromAccessControlEntryLevel(ODAccessControlEntryLevel level) {
    switch (level) {
        case ODAccessControlEntryLevelRead:
            return @"read";
        case ODAccessControlEntryLevelWrite:
            return @"write";
        default:
            @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"Unrecgonized access control entry level" userInfo:@{@"ODAccessControlEntryLevel": @(level)}];
    }
}

@interface ODAccessControlEntry()

- (instancetype)initWithAccessLevel:(ODAccessControlEntryLevel)accessLevel
                             userID:(ODUserRecordID *)userID NS_DESIGNATED_INITIALIZER;
- (instancetype)initWithAccessLevel:(ODAccessControlEntryLevel)accessLevel
                           relation:(ODRelation *)relation NS_DESIGNATED_INITIALIZER;

@end

@implementation ODAccessControlEntry

- (BOOL)isEqualToAccessControlEntry:(ODAccessControlEntry *)entry
{
    if (!entry) {
        return NO;
    }

    return (
            self.entryType == entry.entryType &&
            self.accessLevel == entry.accessLevel &&
            ((self.relation == nil && entry.relation == nil) || [self.relation isEqualToRelation:entry.relation]) &&
            ((self.userID == nil && entry.userID == nil) || [self.userID isEqualToUserRecordID:entry.userID])
            );
}

- (BOOL)isEqual:(id)object
{
    if (self == object) {
        return YES;
    }

    if (![object isKindOfClass:ODAccessControlEntry.class]) {
        return NO;
    }

    return [self isEqualToAccessControlEntry:object];
}

- (NSUInteger)hash
{
    return (self.entryType << 1 + self.accessLevel) ^ self.relation.hash ^ self.userID.hash;
}

- (instancetype)initWithAccessLevel:(ODAccessControlEntryLevel)accessLevel
                             userID:(ODUserRecordID *)userID
{
    self = [super init];
    if (self) {
        _entryType = ODAccessControlEntryTypeDirect;
        _accessLevel = accessLevel;
        _userID = [userID copy];
    }
    return self;
}

- (instancetype)initWithAccessLevel:(ODAccessControlEntryLevel)accessLevel
                           relation:(ODRelation *)relation
{
    self = [super init];
    if (self) {
        _entryType = ODAccessControlEntryTypeRelation;
        _accessLevel = accessLevel;
        _relation = relation;
    }
    return self;
}

+ (instancetype)readEntryForUser:(ODUser *)user
{
    return [self readEntryForUserID:user.recordID];
}

+ (instancetype)readEntryForUserID:(ODUserRecordID *)userID
{
    return [[self alloc] initWithAccessLevel:ODAccessControlEntryLevelRead userID:userID];
}

+ (instancetype)readEntryForRelation:(ODRelation *)relation
{
    return [[self alloc] initWithAccessLevel:ODAccessControlEntryLevelRead relation:relation];
}

+ (instancetype)writeEntryForUser:(ODUser *)user
{
    return [self writeEntryForUserID:user.recordID];
}

+ (instancetype)writeEntryForUserID:(ODUserRecordID *)userID
{
    return [[self alloc] initWithAccessLevel:ODAccessControlEntryLevelWrite userID:userID];
}

+ (instancetype)writeEntryForRelation:(ODRelation *)relation
{
    return [[self alloc] initWithAccessLevel:ODAccessControlEntryLevelWrite relation:relation];
}

@end
