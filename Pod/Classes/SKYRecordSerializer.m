//
//  SKYRecordSerializer.m
//  askq
//
//  Created by Patrick Cheung on 9/2/15.
//  Copyright (c) 2015 Rocky Chan. All rights reserved.
//

#import "SKYAccessControlSerializer.h"
#import "SKYRecordSerializer.h"
#import "SKYRecord.h"
#import "SKYUserRecordID.h"
#import "SKYRecordID.h"
#import "SKYUser.h"
#import "SKYRecordSerialization.h"
#import "SKYReference.h"
#import "SKYDataSerialization.h"

@implementation SKYRecordSerializer

+ (instancetype)serializer
{
    return [[SKYRecordSerializer alloc] init];
}

- (NSDictionary *)dictionaryWithRecord:(SKYRecord *)record
{
    NSMutableDictionary *payload = [NSMutableDictionary dictionary];
    [record.dictionary enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [payload setObject:[SKYDataSerialization serializeObject:obj]
                    forKey:key];
    }];

    payload[SKYRecordSerializationRecordIDKey] = record.recordID.canonicalString;
    payload[SKYRecordSerializationRecordTypeKey] = @"record";

    // NOTE(limouren): this checking is mostly for test cases.
    // It is not expected for a record deserialized from web response to have
    // nil accessControl.
    if (record.accessControl) {
        id serializedAccessControl = [[SKYAccessControlSerializer serializer] arrayWithAccessControl:record.accessControl];
        if (serializedAccessControl == nil) {
            serializedAccessControl = [NSNull null];
        }
        payload[SKYRecordSerializationRecordAccessControlKey] = serializedAccessControl;
    }
    
    // Serialize each value in transient dictionary
    if (self.serializeTransientDictionary) {
        __block NSMutableDictionary *transientPayload = nil;
        [record.transient enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            if (!transientPayload) {
                transientPayload = [NSMutableDictionary dictionary];
            }
            transientPayload[key] = [SKYDataSerialization serializeObject:obj];
        }];
        if (transientPayload) {
            payload[SKYRecordSerializationRecordTransientKey] = transientPayload;
        }
    }

    NSAssert(payload, @"payload is nil");
    return payload;
}

- (NSData *)JSONDataWithRecord:(SKYRecord *)record error:(NSError *__autoreleasing *)error
{
    return [NSJSONSerialization dataWithJSONObject:[self dictionaryWithRecord:record]
                                           options:0
                                             error:error];
}

@end
