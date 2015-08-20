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
    if ([recordID.recordType isEqualToString:@"user"]) {
        ODUserRecordID *userRecordID = [[ODUserRecordID alloc] initWithCanonicalString:recordID.canonicalString];
        record = [[ODUser alloc] initWithUserRecordID:userRecordID
                                                       data:recordData];
    } else {
        record = [[ODRecord alloc] initWithRecordID:recordID
                                               data:recordData];
    }

    NSString *ownerID = obj[ODRecordSerializationRecordOwnerIDKey];
    if (ownerID.length) {
        record.creatorUserRecordID = [ODUserRecordID recordIDWithUsername:ownerID];
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
            [record.transient setObject:[ODDataSerialization deserializeObjectWithValue:obj]
                                 forKey:key];
        }];
    } else {
        NSLog(@"Transient dictionary is nil or of unexpected type.");
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
