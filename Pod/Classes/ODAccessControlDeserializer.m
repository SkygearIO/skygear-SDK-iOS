//
//  ODAccessControlDeserializer.m
//  Pods
//
//  Created by Kenji Pa on 12/6/15.
//
//

#import "ODAccessControlDeserializer.h"

#import "ODAccessControl_Private.h"
#import "ODAccessControlEntry.h"
#import "ODUserRecordID_Private.h"

@implementation ODAccessControlDeserializer

+ (instancetype)deserializer
{
    return [[ODAccessControlDeserializer alloc] init];
}

- (ODAccessControl *)accessControlWithArray:(NSArray *)array
{
    if (array == nil) {
        return [ODAccessControl publicReadWriteAccessControl];
    } else {
        NSMutableArray *entries = [NSMutableArray arrayWithCapacity:array.count];
        for (NSDictionary *entryDict in array) {
            ODAccessControlEntry *entry = [self accessControlEntryWithDictionary:entryDict];
            if (entry != nil) {
                [entries addObject:entry];
            }
        }

        return [ODAccessControl accessControlWithEntries:entries];
    }
}

- (ODAccessControlEntry *)accessControlEntryWithDictionary:(NSDictionary *)dictionary
{
    ODAccessControlEntryLevel level;
    NSString *rawLevel = dictionary[@"level"];
    if ([rawLevel isEqualToString:@"read"]) {
        level = ODAccessControlEntryLevelRead;
    } else if ([rawLevel isEqualToString:@"write"]) {
        level = ODAccessControlEntryLevelWrite;
    } else {
        NSLog(@"Failed to deserialize access control entry: unrecgonized level: %@", rawLevel);
        return nil;
    }

    NSString *rawRelation = dictionary[@"relation"];
    if ([rawRelation isEqualToString:@"$direct"]) {
        NSString *rawUserID = dictionary[@"user_id"];
        return [[ODAccessControlEntry alloc] initWithAccessLevel:level userID:[ODUserRecordID recordIDWithUsername:rawUserID]];
    } else {
        ODRelation *relation;
        if ([rawRelation isEqualToString:@"follow"]) {
            relation = [ODRelation relationFollow];
        } else if ([rawRelation isEqualToString:@"friend"]) {
            relation = [ODRelation relationFriend];
        } else {
            NSLog(@"Failed to deserialize access control entry: unrecgonized relation %@", rawRelation);
            return nil;
        }

        return [[ODAccessControlEntry alloc] initWithAccessLevel:level relation:relation];
    }
}

@end
