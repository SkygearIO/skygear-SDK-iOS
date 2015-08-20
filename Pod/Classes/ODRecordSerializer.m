//
//  ODRecordSerializer.m
//  askq
//
//  Created by Patrick Cheung on 9/2/15.
//  Copyright (c) 2015 Rocky Chan. All rights reserved.
//

#import "ODAccessControlSerializer.h"
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

    // NOTE(limouren): this checking is mostly for test cases.
    // It is not expected for a record deserialized from web response to have
    // nil accessControl.
    if (record.accessControl) {
        id serializedAccessControl = [[ODAccessControlSerializer serializer] arrayWithAccessControl:record.accessControl];
        if (serializedAccessControl == nil) {
            serializedAccessControl = [NSNull null];
        }
        payload[ODRecordSerializationRecordAccessControlKey] = serializedAccessControl;
    }
    
    // Serialize each value in transient dictionary
    if (self.serializeTransientDictionary) {
        __block NSMutableDictionary *transientPayload = nil;
        [record.transient enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            if (!transientPayload) {
                transientPayload = [NSMutableDictionary dictionary];
            }
            transientPayload[key] = [ODDataSerialization serializeObject:obj];
        }];
        if (transientPayload) {
            payload[ODRecordSerializationRecordTransientKey] = transientPayload;
        }
    }

    NSAssert(payload, @"payload is nil");
    return payload;
}

- (NSData *)JSONDataWithRecord:(ODRecord *)record error:(NSError *__autoreleasing *)error
{
    return [NSJSONSerialization dataWithJSONObject:[self dictionaryWithRecord:record]
                                           options:0
                                             error:error];
}

@end
