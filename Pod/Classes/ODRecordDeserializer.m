//
//  ODRecordDeserializer.m
//  askq
//
//  Created by Patrick Cheung on 9/2/15.
//  Copyright (c) 2015 Rocky Chan. All rights reserved.
//

#import "ODRecordDeserializer.h"
#import "ODRecord.h"
#import "ODUserRecordID.h"
#import "ODRecordID.h"
#import "ODUser.h"
#import "ODRecordSerialization.h"
#import "ODReference.h"

@implementation ODRecordDeserializer

+ (instancetype)deserializer
{
    return [[ODRecordDeserializer alloc] init];
}

- (id)deserializeObjectWithType:(NSString *)type data:(NSDictionary *)data
{
    id obj = nil;
    if ([type isEqualToString:@"date"]) {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZZZZZ"];
        obj = [formatter dateFromString:data[@"$date"]];
    } else if ([type isEqualToString:@"ref"]) {
        obj = [[ODReference alloc] initWithRecordID:[[ODRecordID alloc] initWithRecordName:data[@"$id"]]];
    }
    return obj;
}

- (id)objectWithValue:(id)value
{
    if (!value) {
        return nil;
    }
    
    if ([value isKindOfClass:[NSArray class]]) {
        NSMutableArray *newArray = [NSMutableArray array];
        [(NSArray *)value enumerateObjectsUsingBlock:^(id valueInArray, NSUInteger idx, BOOL *stop) {
            [newArray addObject:[self objectWithValue:valueInArray]];
        }];
        return newArray;
    } else if ([value isKindOfClass:[NSDictionary class]]) {
        NSString *type = [(NSDictionary *)value objectForKey:ODRecordSerializationCustomTypeKey];
        if (type) {
            return [self deserializeObjectWithType:type data:value];
        } else {
            NSMutableDictionary *newDictionary = [NSMutableDictionary dictionary];
            [(NSDictionary *)value enumerateKeysAndObjectsUsingBlock:^(id key, id valueInDictionary, BOOL *stop) {
                [newDictionary setObject:[self objectWithValue:valueInDictionary]
                                  forKey:key];
            }];
            return newDictionary;
        }
    } else {
        return value;
    }

    
    id obj = nil;
    if ([value isKindOfClass:[NSDictionary class]]) {
        NSString *type = [(NSDictionary *)value objectForKey:ODRecordSerializationCustomTypeKey];
        if (type) {
            obj = [self deserializeObjectWithType:type data:value];
        } else {
            obj = value;
        }
    } else {
        obj = value;
    }
    return obj;
}

- (ODRecord *)recordWithDictionary:(NSDictionary *)obj
{
    NSMutableDictionary *recordData = [NSMutableDictionary dictionary];
    [obj enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        if (![(NSString *)key hasPrefix:@"_"]) {
            [recordData setObject:[self objectWithValue:obj]
                           forKey:key];
        }
    }];
    
    ODRecordID *recordID;
    ODRecord *record;
    NSString *recordType = obj[ODRecordSerializationRecordTypeKey];
    NSString *stringID = obj[ODRecordSerializationRecordIDKey];
    if ([recordType isEqualToString:@"user"]) {
        recordID = [[ODUserRecordID alloc] initWithRecordName:stringID];
        record = [[ODUser alloc] initWithRecordType:recordType
                                           recordID:recordID
                                               data:recordData];
    } else {
        recordID = [[ODRecordID alloc] initWithRecordName:stringID];
        record = [[ODRecord alloc] initWithRecordType:recordType
                                             recordID:recordID
                                                 data:recordData];
    }
    
    return record;
}

@end
