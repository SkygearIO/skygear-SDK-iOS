//
//  SKYAccessControlDeserializer.m
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

#import "SKYAccessControlDeserializer.h"

#import "SKYAccessControlEntry.h"
#import "SKYAccessControl_Private.h"

@implementation SKYAccessControlDeserializer

+ (instancetype)deserializer
{
    return [[SKYAccessControlDeserializer alloc] init];
}

- (SKYAccessControl *)accessControlWithArray:(NSArray<NSDictionary *> *)array
{
    if (array == nil) {
        return nil;
    }

    NSMutableArray *entries = [NSMutableArray arrayWithCapacity:array.count];
    for (NSDictionary *entryDict in array) {
        SKYAccessControlEntry *entry = [self accessControlEntryWithDictionary:entryDict];
        if (entry != nil) {
            [entries addObject:entry];
        }
    }

    return [SKYAccessControl accessControlWithEntries:entries];
}

- (SKYAccessControlEntry *)accessControlEntryWithDictionary:(NSDictionary *)dictionary
{
    SKYAccessControlEntryLevel level;
    NSString *rawLevel = dictionary[@"level"];
    if ([rawLevel isEqualToString:@"read"]) {
        level = SKYAccessControlEntryLevelRead;
    } else if ([rawLevel isEqualToString:@"write"]) {
        level = SKYAccessControlEntryLevelWrite;
    } else {
        NSLog(@"Failed to deserialize access control entry: unrecgonized level: %@", rawLevel);
        return nil;
    }

    NSString *rawRelation = dictionary[@"relation"];
    NSString *roleName = dictionary[@"role"];
    NSString *userID = dictionary[@"user_id"];
    BOOL isPublic = [dictionary[@"public"] boolValue];
    if (isPublic) {
        return [[SKYAccessControlEntry alloc] initWithPublicAccessLevel:level];
    } else if (roleName != nil) {
        SKYRole *role = [SKYRole roleWithName:roleName];
        return [[SKYAccessControlEntry alloc] initWithAccessLevel:level role:role];
    } else if (userID != nil) {
        return [[SKYAccessControlEntry alloc] initWithAccessLevel:level userID:userID];
    } else {
        SKYRelation *relation;
        if ([rawRelation isEqualToString:@"follow"]) {
            relation = [SKYRelation followedRelation];
        } else if ([rawRelation isEqualToString:@"friend"]) {
            relation = [SKYRelation friendRelation];
        } else {
            NSLog(@"Failed to deserialize access control entry: unrecgonized relation %@",
                  rawRelation);
            return nil;
        }

        return [[SKYAccessControlEntry alloc] initWithAccessLevel:level relation:relation];
    }
}

@end
