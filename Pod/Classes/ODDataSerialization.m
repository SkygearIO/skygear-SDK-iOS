//
//  ODDataSerialization.m
//  Pods
//
//  Created by Patrick Cheung on 14/3/15.
//
//

#import "ODDataSerialization.h"
#import "ODDataSerialization.h"
#import "ODReference.h"

const NSString *ODDataSerializationCustomTypeKey = @"$type";
const NSString *ODDataSerializationReferenceType = @"ref";
const NSString *ODDataSerializationDateType = @"date";

@implementation ODDataSerialization

+ (id)deserializeSimpleObjectWithType:(NSString *)type value:(NSDictionary *)data
{
    id obj = nil;
    if ([type isEqualToString:(NSString *)ODDataSerializationDateType]) {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZZZZZ"];
        obj = [formatter dateFromString:data[@"$date"]];
    } else if ([type isEqualToString:(NSString *)ODDataSerializationReferenceType]) {
        obj = [[ODReference alloc] initWithRecordID:[[ODRecordID alloc] initWithRecordName:data[@"$id"]]];
    }
    return obj;
}

+ (id)deserializeObjectWithValue:(id)value
{
    if (!value) {
        return nil;
    } else if ([value isKindOfClass:[NSArray class]]) {
        NSMutableArray *newArray = [NSMutableArray array];
        [(NSArray *)value enumerateObjectsUsingBlock:^(id valueInArray, NSUInteger idx, BOOL *stop) {
            [newArray addObject:[self deserializeObjectWithValue:valueInArray]];
        }];
        return newArray;
    } else if ([value isKindOfClass:[NSDictionary class]]) {
        NSString *type = [(NSDictionary *)value objectForKey:ODDataSerializationCustomTypeKey];
        if (type) {
            return [self deserializeSimpleObjectWithType:type value:value];
        } else {
            NSMutableDictionary *newDictionary = [NSMutableDictionary dictionary];
            [(NSDictionary *)value enumerateKeysAndObjectsUsingBlock:^(id key, id valueInDictionary, BOOL *stop) {
                [newDictionary setObject:[self deserializeObjectWithValue:valueInDictionary]
                                  forKey:key];
            }];
            return newDictionary;
        }
    } else {
        return value;
    }
}

+ (id)serializeSimpleObject:(id)obj
{
    id data = nil;
    if ([obj isKindOfClass:[NSDate class]]) {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZZZZZ"];
        data = @{
                 ODDataSerializationCustomTypeKey: ODDataSerializationDateType,
                 @"$date": [formatter stringFromDate:obj],
                 };
    } else if ([obj isKindOfClass:[ODReference class]]) {
        data = @{
                 ODDataSerializationCustomTypeKey: ODDataSerializationReferenceType,
                 @"$id": [[(ODReference*)obj recordID] recordName],
                 };
    } else {
        data = obj;
    }
    return data;
}

+ (id)serializeObject:(id)obj
{
    if (!obj) {
        return nil;
    }
    
    if ([obj isKindOfClass:[NSArray class]]) {
        NSMutableArray *newArray = [NSMutableArray array];
        [(NSArray *)obj enumerateObjectsUsingBlock:^(id objInArray, NSUInteger idx, BOOL *stop) {
            [newArray addObject:[self serializeObject:objInArray]];
        }];
        return newArray;
    } else if ([obj isKindOfClass:[NSDictionary class]]) {
        NSMutableDictionary *newDictionary = [NSMutableDictionary dictionary];
        [(NSDictionary *)obj enumerateKeysAndObjectsUsingBlock:^(id key, id objInDictionary, BOOL *stop) {
            [newDictionary setObject:[self serializeObject:objInDictionary]
                              forKey:key];
        }];
        return newDictionary;
    } else {
        return [self serializeSimpleObject:obj];
    }
}


@end
