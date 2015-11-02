//
//  SKYAccessControlSerializer.m
//  Pods
//
//  Created by Kenji Pa on 11/6/15.
//
//

#import "SKYAccessControlSerializer.h"

#import "SKYAccessControlEntry.h"

@implementation SKYAccessControlSerializer

+ (instancetype)serializer
{
    return [[self alloc] init];
}

- (NSArray *)arrayWithAccessControl:(SKYAccessControl *)accessControl
{
    NSMutableArray *array = nil;

    if (accessControl == nil) {
        return nil;
    } else if (accessControl.public) {
        // do nothing, let it returns nil
    } else {
        array = [NSMutableArray array];
        for (SKYAccessControlEntry *entry in accessControl) {
            [array addObject:[self dictionaryWithAccessControlEntry:entry]];
        }
    }

    return array;
}

- (NSDictionary *)dictionaryWithAccessControlEntry:(SKYAccessControlEntry *)entry
{
    NSDictionary *dict;
    switch (entry.entryType) {
        case SKYAccessControlEntryTypeRelation:
            dict = [self dictionaryWithRelationalAccessControlEntry:entry];
            break;
        case SKYAccessControlEntryTypeDirect:
            dict = [self dictionaryWithDirectAccessControlEntry:entry];
            break;
        default:
            @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                           reason:@"Unrecgonized access control entry type"
                                         userInfo:@{
                                             @"SKYAccessControlEntryType" : @(entry.entryType)
                                         }];
    }
    return dict;
}

- (NSDictionary *)dictionaryWithRelationalAccessControlEntry:(SKYAccessControlEntry *)entry
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    dict[@"relation"] = entry.relation.name;
    dict[@"level"] = NSStringFromAccessControlEntryLevel(entry.accessLevel);
    return dict;
}

- (NSDictionary *)dictionaryWithDirectAccessControlEntry:(SKYAccessControlEntry *)entry
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    dict[@"relation"] = @"$direct";
    dict[@"level"] = NSStringFromAccessControlEntryLevel(entry.accessLevel);
    dict[@"user_id"] = entry.userID.username;
    return dict;
}

@end
