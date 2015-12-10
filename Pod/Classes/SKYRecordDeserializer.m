//
//  SKYRecordDeserializer.m
//  SkyKit
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

#import "SKYAccessControlDeserializer.h"
#import "SKYRecordDeserializer.h"
#import "SKYRecord_Private.h"
#import "SKYUserRecordID.h"
#import "SKYRecordID.h"
#import "SKYUser.h"
#import "SKYUserRecordID_Private.h"
#import "SKYRecordSerialization.h"
#import "SKYReference.h"
#import "SKYDataSerialization.h"

@implementation SKYRecordDeserializer

+ (instancetype)deserializer
{
    return [[SKYRecordDeserializer alloc] init];
}

+ (NSDateFormatter *)dateFormatter
{
    static NSDateFormatter *formatter;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSSSSZZZZZ"];
    });

    return formatter;
}

- (BOOL)isRecordDictionary:(NSDictionary *)obj
{
    return [obj isKindOfClass:[NSDictionary class]] &&
           [obj[SKYRecordSerializationRecordTypeKey] isEqualToString:@"record"];
}

- (SKYRecord *)recordWithDictionary:(NSDictionary *)obj
{
    NSMutableDictionary *recordData = [NSMutableDictionary dictionary];
    [obj enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        if (![(NSString *)key hasPrefix:@"_"]) {
            [recordData setObject:[SKYDataSerialization deserializeObjectWithValue:obj] forKey:key];
        }
    }];

    SKYRecordID *recordID =
        [[SKYRecordID alloc] initWithCanonicalString:obj[SKYRecordSerializationRecordIDKey]];
    SKYRecord *record = [[SKYRecord alloc] initWithRecordID:recordID data:recordData];

    NSString *ownerID = obj[SKYRecordSerializationRecordOwnerIDKey];
    if (ownerID.length) {
        record.ownerUserRecordID = [SKYUserRecordID recordIDWithUsername:ownerID];
    }

    NSDateFormatter *formatter = [self.class dateFormatter];
    NSString *createdAt = obj[SKYRecordSerializationRecordCreatedAtKey];
    if (createdAt.length) {
        record.creationDate = [formatter dateFromString:createdAt];
    }
    NSString *creatorID = obj[SKYRecordSerializationRecordCreatorIDKey];
    if (creatorID.length) {
        record.creatorUserRecordID = [SKYUserRecordID recordIDWithUsername:creatorID];
    }
    NSString *updatedAt = obj[SKYRecordSerializationRecordUpdatedAtKey];
    if (updatedAt.length) {
        record.modificationDate = [formatter dateFromString:updatedAt];
    }
    NSString *updaterID = obj[SKYRecordSerializationRecordUpdaterIDKey];
    if (updaterID.length) {
        record.lastModifiedUserRecordID = [SKYUserRecordID recordIDWithUsername:updaterID];
    }

    id accessControl = obj[SKYRecordSerializationRecordAccessControlKey];
    if (accessControl == nil) {
        // do nothing
    } else {
        SKYAccessControlDeserializer *deserializer = [SKYAccessControlDeserializer deserializer];
        NSArray *rawAccessControl;
        if ([accessControl isKindOfClass:NSNull.class]) {
            rawAccessControl = nil;
        } else {
            rawAccessControl = (NSArray *)accessControl;
        }

        record.accessControl = [deserializer accessControlWithArray:rawAccessControl];
    }

    NSDictionary *transient = obj[SKYRecordSerializationRecordTransientKey];
    if ([transient isKindOfClass:[NSDictionary class]]) {
        [transient enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            id deserializedObject = nil;
            if ([self isRecordDictionary:obj]) {
                deserializedObject = [self recordWithDictionary:obj];
            } else {
                deserializedObject = [SKYDataSerialization deserializeObjectWithValue:obj];
            }
            [record.transient setObject:deserializedObject forKey:key];
        }];
    } else if (transient != nil) {
        NSLog(@"Ignored transient field when deserializing record %@ because of unexpected object "
              @"%@.",
              recordID.canonicalString, NSStringFromClass([transient class]));
    }

    return record;
}

- (SKYRecord *)recordWithJSONData:(NSData *)data error:(NSError *__autoreleasing *)error
{
    NSDictionary *jsonObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:error];
    if (jsonObject) {
        return [self recordWithDictionary:jsonObject];
    } else {
        return nil;
    }
}

@end
