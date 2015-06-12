//
//  ODAccessControlSerializer.m
//  Pods
//
//  Created by Kenji Pa on 11/6/15.
//
//

#import "ODAccessControlSerializer.h"

#import "ODAccessControlEntry.h"

@implementation ODAccessControlSerializer

+ (instancetype)serializer
{
    return [[self alloc] init];
}

- (NSArray *)arrayWithAccessControl:(ODAccessControl *)accessControl
{
    NSMutableArray *array = nil;

    if (accessControl == nil) {
        return nil;
    } else if (accessControl.public) {
        // do nothing, let it returns nil
    } else {
        array = [NSMutableArray array];
        for (ODAccessControlEntry *entry in accessControl) {
            [array addObject:[self dictionaryWithAccessControlEntry:entry]];
        }
    }

    return array;
}

- (NSDictionary *)dictionaryWithAccessControlEntry:(ODAccessControlEntry *)entry
{
    NSDictionary *dict;
    switch (entry.entryType) {
        case ODAccessControlEntryTypeRelation:
            dict = [self dictionaryWithRelationalAccessControlEntry:entry];
            break;
        case ODAccessControlEntryTypeDirect:
            dict = [self dictionaryWithDirectAccessControlEntry:entry];
            break;
        default:
            @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"Unrecgonized access control entry type" userInfo:@{@"ODAccessControlEntryType": @(entry.entryType)}];

    }
    return dict;
}

- (NSDictionary *)dictionaryWithRelationalAccessControlEntry:(ODAccessControlEntry *)entry
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    dict[@"relation"] = entry.relation.name;
    dict[@"level"] = NSStringFromAccessControlEntryLevel(entry.accessLevel);
    return dict;
}

- (NSDictionary *)dictionaryWithDirectAccessControlEntry:(ODAccessControlEntry *)entry
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    dict[@"relation"] = @"$direct";
    dict[@"level"] = NSStringFromAccessControlEntryLevel(entry.accessLevel);
    dict[@"user_id"] = entry.userID.username;
    return dict;
}

@end
