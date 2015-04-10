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
#import "ODDataSerialization.h"

@implementation ODRecordSerializer

+ (instancetype)serializer
{
    return [[ODRecordSerializer alloc] init];
}


- (NSDictionary *)dictionaryWithRecord:(ODRecord *)record
{
    NSMutableDictionary *payload = [NSMutableDictionary dictionary];
    [record.dictionary enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [payload setObject:[ODDataSerialization serializeObject:obj]
                    forKey:key];
    }];
    
    payload[ODRecordSerializationRecordIDKey] = record.recordID.canonicalString;
    payload[ODRecordSerializationRecordTypeKey] = @"record";
    NSAssert(payload, @"payload is nil");
    return payload;
}

@end
