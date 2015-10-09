//
//  SKYAccessControlDeserializer.m
//  Pods
//
//  Created by Kenji Pa on 12/6/15.
//
//

#import "SKYAccessControlDeserializer.h"

#import "SKYAccessControl_Private.h"
#import "SKYAccessControlEntry.h"
#import "SKYUserRecordID_Private.h"

@implementation SKYAccessControlDeserializer

+ (instancetype)deserializer
{
    return [[SKYAccessControlDeserializer alloc] init];
}

- (SKYAccessControl *)accessControlWithArray:(NSArray *)array
{
    if (array == nil) {
        return [SKYAccessControl publicReadWriteAccessControl];
    } else {
        NSMutableArray *entries = [NSMutableArray arrayWithCapacity:array.count];
        for (NSDictionary *entryDict in array) {
            SKYAccessControlEntry *entry = [self accessControlEntryWithDictionary:entryDict];
            if (entry != nil) {
                [entries addObject:entry];
            }
        }

        return [SKYAccessControl accessControlWithEntries:entries];
    }
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
    if ([rawRelation isEqualToString:@"$direct"]) {
        NSString *rawUserID = dictionary[@"user_id"];
        return [[SKYAccessControlEntry alloc] initWithAccessLevel:level userID:[SKYUserRecordID recordIDWithUsername:rawUserID]];
    } else {
        SKYRelation *relation;
        if ([rawRelation isEqualToString:@"follow"]) {
            relation = [SKYRelation relationFollow];
        } else if ([rawRelation isEqualToString:@"friend"]) {
            relation = [SKYRelation relationFriend];
        } else {
            NSLog(@"Failed to deserialize access control entry: unrecgonized relation %@", rawRelation);
            return nil;
        }

        return [[SKYAccessControlEntry alloc] initWithAccessLevel:level relation:relation];
    }
}

@end
