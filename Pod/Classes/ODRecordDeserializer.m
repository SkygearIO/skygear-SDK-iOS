//
//  ODRecordDeserializer.m
//  askq
//
//  Created by Patrick Cheung on 9/2/15.
//  Copyright (c) 2015 Rocky Chan. All rights reserved.
//

#import "ODAccessControlDeserializer.h"
#import "ODRecordDeserializer.h"
#import "ODRecord_Private.h"
#import "ODUserRecordID.h"
#import "ODRecordID.h"
#import "ODUser.h"
#import "ODUserRecordID_Private.h"
#import "ODRecordSerialization.h"
#import "ODReference.h"
#import "ODDataSerialization.h"

@implementation ODRecordDeserializer

+ (instancetype)deserializer
{
    return [[ODRecordDeserializer alloc] init];
}

+ (NSDateFormatter *)dateFormatter
{
    static NSDateFormatter *formatter;
    static dispatch_once_t onceToken;

    dispatch_once (&onceToken, ^{
        formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZZZZZ"];
    });

    return formatter;
}

- (BOOL)isRecordDictionary:(NSDictionary *)obj
{
    return [obj isKindOfClass:[NSDictionary class]] && [obj[ODRecordSerializationRecordTypeKey] isEqualToString:@"record"];
}

- (ODRecord *)recordWithDictionary:(NSDictionary *)obj
{
    NSMutableDictionary *recordData = [NSMutableDictionary dictionary];
    [obj enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        if (![(NSString *)key hasPrefix:@"_"]) {
            [recordData setObject:[ODDataSerialization deserializeObjectWithValue:obj]
                           forKey:key];
        }
    }];
    
    ODRecordID *recordID = [[ODRecordID alloc] initWithCanonicalString:obj[ODRecordSerializationRecordIDKey]];
    ODRecord *record;
    if ([recordID.recordType isEqualToString:@"_user"]) {
        ODUserRecordID *userRecordID = [[ODUserRecordID alloc] initWithCanonicalString:recordID.canonicalString];
        record = [[ODUser alloc] initWithUserRecordID:userRecordID
                                                       data:recordData];
    } else {
        record = [[ODRecord alloc] initWithRecordID:recordID
                                               data:recordData];
    }

    NSString *ownerID = obj[ODRecordSerializationRecordOwnerIDKey];
    if (ownerID.length) {
        record.ownerUserRecordID = [ODUserRecordID recordIDWithUsername:ownerID];
    }

    NSDateFormatter *formatter = [self.class dateFormatter];
    NSString *createdAt = obj[ODRecordSerializationRecordCreatedAtKey];
    if (createdAt.length) {
        record.creationDate = [formatter dateFromString:createdAt];
    }
    NSString *creatorID = obj[ODRecordSerializationRecordCreatorIDKey];
    if (creatorID.length) {
        record.creatorUserRecordID = [ODUserRecordID recordIDWithUsername:creatorID];
    }
    NSString *updatedAt = obj[ODRecordSerializationRecordUpdatedAtKey];
    if (updatedAt.length) {
        record.modificationDate = [formatter dateFromString:updatedAt];
    }
    NSString *updaterID = obj[ODRecordSerializationRecordUpdaterIDKey];
    if (updaterID.length) {
        record.lastModifiedUserRecordID = [ODUserRecordID recordIDWithUsername:updaterID];
    }


    id accessControl = obj[ODRecordSerializationRecordAccessControlKey];
    if (accessControl == nil) {
        // do nothing
    } else {
        ODAccessControlDeserializer *deserializer = [ODAccessControlDeserializer deserializer];
        NSArray *rawAccessControl;
        if ([accessControl isKindOfClass:NSNull.class]) {
            rawAccessControl = nil;
        } else {
            rawAccessControl = (NSArray *)accessControl;
        }

        record.accessControl = [deserializer accessControlWithArray:rawAccessControl];
    }
    
    NSDictionary *transient = obj[ODRecordSerializationRecordTransientKey];
    if ([transient isKindOfClass:[NSDictionary class]]) {
        [transient enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            id deserializedObject = nil;
            if ([self isRecordDictionary:obj]) {
                deserializedObject = [self recordWithDictionary:obj];
            } else {
                deserializedObject = [ODDataSerialization deserializeObjectWithValue:obj];
            }
            [record.transient setObject:deserializedObject
                                 forKey:key];
        }];
    } else if (transient != nil) {
        NSLog(@"Ignored transient field when deserializing record %@ because of unexpected object %@.",
              recordID.canonicalString, NSStringFromClass([transient class]));
    }

    return record;
}

- (ODRecord *)recordWithJSONData:(NSData *)data error:(NSError *__autoreleasing *)error
{
    NSDictionary *jsonObject = [NSJSONSerialization JSONObjectWithData:data
                                                               options:0
                                                                 error:error];
    if (jsonObject) {
        return [self recordWithDictionary:jsonObject];
    } else {
        return nil;
    }
}

@end
