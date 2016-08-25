//
//  SKYRecordSerializer.m
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

#import "SKYRecordSerializer.h"
#import "SKYAccessControlSerializer.h"
#import "SKYRecord.h"

#import "SKYDataSerialization.h"
#import "SKYRecordID.h"
#import "SKYRecordSerialization.h"
#import "SKYReference.h"
#import "SKYUser.h"

@implementation SKYRecordSerializer

+ (instancetype)serializer
{
    return [[SKYRecordSerializer alloc] init];
}

- (NSDictionary *)dictionaryWithRecord:(SKYRecord *)record
{
    NSMutableDictionary *payload = [NSMutableDictionary dictionary];
    [record.dictionary enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [payload setObject:[SKYDataSerialization serializeObject:obj] forKey:key];
    }];

    payload[SKYRecordSerializationRecordIDKey] = record.recordID.canonicalString;
    payload[SKYRecordSerializationRecordTypeKey] = @"record";

    if (record.creationDate) {
        payload[SKYRecordSerializationRecordCreatedAtKey] =
            [SKYDataSerialization stringFromDate:record.creationDate];
    }

    if (record.creatorUserRecordID.length) {
        payload[SKYRecordSerializationRecordCreatorIDKey] = record.creatorUserRecordID;
    }

    if (record.modificationDate) {
        payload[SKYRecordSerializationRecordUpdatedAtKey] =
            [SKYDataSerialization stringFromDate:record.modificationDate];
    }

    if (record.lastModifiedUserRecordID.length) {
        payload[SKYRecordSerializationRecordUpdaterIDKey] = record.lastModifiedUserRecordID;
    }

    if (record.ownerUserRecordID) {
        payload[SKYRecordSerializationRecordOwnerIDKey] = record.ownerUserRecordID;
    }

    // NOTE(limouren): this checking is mostly for test cases.
    // It is not expected for a record deserialized from web response to have
    // nil accessControl.
    if (record.accessControl) {
        id serializedAccessControl =
            [[SKYAccessControlSerializer serializer] arrayWithAccessControl:record.accessControl];
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
