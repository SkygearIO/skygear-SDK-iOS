//
//  ODRecordSerializer.m
//  askq
//
//  Created by Patrick Cheung on 9/2/15.
//  Copyright (c) 2015 Rocky Chan. All rights reserved.
//

#import "ODRecordSerializer.h"
#import "ODRecord.h"
#import "ODUserRecordID.h"
#import "ODRecordID.h"
#import "ODUser.h"
#import "ODRecordSerialization.h"
#import "ODReference.h"

@implementation ODRecordSerializer

+ (instancetype)serializer
{
    return [[ODRecordSerializer alloc] init];
}

- (id)serializeObject:(id)obj
{
    id data = nil;
    if ([obj isKindOfClass:[NSDate class]]) {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZZZZZ"];
        data = @{
                 ODRecordSerializationCustomTypeKey: @"date",
                 @"$date": [formatter stringFromDate:obj],
                 };
    } else if ([obj isKindOfClass:[ODReference class]]) {
        data = @{
                 ODRecordSerializationCustomTypeKey: @"ref",
                 @"$id": [[(ODReference*)obj recordID] recordName],
                 };
    } else {
        data = obj;
    }
    return data;
}

- (id)valueWithObject:(id)obj
{
    if (!obj) {
        return nil;
    }
    
    if ([obj isKindOfClass:[NSArray class]]) {
        NSMutableArray *newArray = [NSMutableArray array];
        [(NSArray *)obj enumerateObjectsUsingBlock:^(id objInArray, NSUInteger idx, BOOL *stop) {
            [newArray addObject:[self valueWithObject:objInArray]];
        }];
        return newArray;
    } else if ([obj isKindOfClass:[NSDictionary class]]) {
        NSMutableDictionary *newDictionary = [NSMutableDictionary dictionary];
        [(NSDictionary *)obj enumerateKeysAndObjectsUsingBlock:^(id key, id objInDictionary, BOOL *stop) {
            [newDictionary setObject:[self valueWithObject:objInDictionary]
                              forKey:key];
        }];
        return newDictionary;
    } else {
        return [self serializeObject:obj];
    }
}

- (NSDictionary *)dictionaryWithRecord:(ODRecord *)record
{
    NSMutableDictionary *payload = [NSMutableDictionary dictionary];
    [record.dictionary enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [payload setObject:[self valueWithObject:obj]
                    forKey:key];
    }];
    
    payload[ODRecordSerializationRecordIDKey] = record.recordID.recordName;
    payload[ODRecordSerializationRecordTypeKey] = record.recordType;
    return payload;
}

@end
