//
//  SKYAccessControlSerializer.m
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
