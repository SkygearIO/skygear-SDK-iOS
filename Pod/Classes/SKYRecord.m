//
//  SKYRecord.m
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

#import "SKYRecord_Private.h"

#import "SKYAccessControl_Private.h"
#import "SKYReference.h"

NSString *const SKYRecordTypeUserRecord = @"_User";

NSString *SKYRecordConcatenatedID(NSString *recordType, NSString *recordID)
{
    return [NSString stringWithFormat:@"%@/%@", recordType, recordID];
}

NSString *SKYRecordTypeFromConcatenatedID(NSString *concatenatedID)
{
    NSArray *components = [concatenatedID componentsSeparatedByString:@"/"];
    if ([components count] != 2) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException
                                       reason:@"Invalid Record ID string."
                                     userInfo:nil];
    }

    return components[0];
}

NSString *SKYRecordIDFromConcatenatedID(NSString *concatenatedID)
{
    NSArray *components = [concatenatedID componentsSeparatedByString:@"/"];
    if ([components count] != 2) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException
                                       reason:@"Invalid Record ID string."
                                     userInfo:nil];
    }

    return components[1];
}

@interface SKYRecord ()

@property (nonatomic, readonly) NSMutableDictionary *object;

@end

@implementation SKYRecord

- (instancetype)initWithRecordType:(NSString *)recordType
{
    return [self initWithType:recordType recordID:nil data:nil];
}

- (instancetype)initWithType:(NSString *)recordType
{
    return [self initWithType:recordType recordID:nil data:nil];
}

- (instancetype)initWithRecordType:(NSString *)recordType name:(NSString *)recordName
{
    return [self initWithType:recordType recordID:recordName data:nil];
}

- (instancetype)initWithType:(NSString *)recordType recordID:(NSString *)recordID
{
    return [self initWithType:recordType recordID:recordID data:nil];
}

- (instancetype)initWithRecordType:(NSString *)recordType
                              name:(NSString *)recordName
                              data:(NSDictionary<NSString *, id> *)data
{
    return [self initWithType:recordType recordID:recordName data:data];
}

- (instancetype)initWithType:(NSString *)recordType
                    recordID:(NSString *)recordID
                        data:(NSDictionary<NSString *, id> *)data
{
    self = [super init];
    if (self) {
        _recordType = recordType ? [recordType copy] : @"";
        _recordID = recordID ? [recordID copy] : [[NSUUID UUID] UUIDString];
        _object = data ? [data mutableCopy] : [[NSMutableDictionary alloc] init];
        _accessControl = nil;
        _transient = [NSMutableDictionary dictionary];
    }
    return self;
}

#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"
- (instancetype)initWithRecordID:(SKYRecordID *)recordID data:(NSDictionary<NSString *, id> *)data
{
    return [self initWithType:recordID.recordType recordID:recordID.recordName data:data];
}
#pragma GCC diagnostic pop

+ (instancetype)recordWithType:(NSString *)recordType
{
    return [[self alloc] initWithType:recordType recordID:nil data:nil];
}

+ (instancetype)recordWithRecordType:(NSString *)recordType
{
    return [[self alloc] initWithType:recordType recordID:nil data:nil];
}

+ (instancetype)recordWithRecordType:(NSString *)recordType name:(NSString *)recordName
{
    return [[self alloc] initWithType:recordType recordID:recordName data:nil];
}

+ (instancetype)recordWithType:(NSString *)recordType recordID:(NSString *)recordID
{
    return [[self alloc] initWithType:recordType recordID:recordID data:nil];
}

+ (instancetype)recordWithRecordType:(NSString *)recordType
                                name:(NSString *)recordName
                                data:(NSDictionary<NSString *, id> *)data
{
    return [[self alloc] initWithType:recordType recordID:recordName data:data];
}

+ (instancetype)recordWithType:(NSString *)recordType
                      recordID:(NSString *)recordID
                          data:(NSDictionary<NSString *, id> *)data
{
    return [[self alloc] initWithType:recordType recordID:recordID data:data];
}

#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"
+ (instancetype)recordWithRecordID:(SKYRecordID *)recordID data:(NSDictionary<NSString *, id> *)data
{
    return [[self alloc] initWithType:recordID.recordType recordID:recordID.recordName data:data];
}
#pragma GCC diagnostic pop

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone
{
    SKYRecord *record = [[self.class allocWithZone:zone] init];
    record->_recordType = [_recordType copyWithZone:zone];
    record->_recordID = [_recordID copyWithZone:zone];
    record->_object = [_object mutableCopyWithZone:zone];
    record->_transient = [_transient mutableCopyWithZone:zone];
    record->_ownerUserRecordID = [_ownerUserRecordID copyWithZone:zone];
    record->_creationDate = [_creationDate copyWithZone:zone];
    record->_creatorUserRecordID = [_creatorUserRecordID copyWithZone:zone];
    record->_modificationDate = [_modificationDate copyWithZone:zone];
    record->_lastModifiedUserRecordID = [_lastModifiedUserRecordID copyWithZone:zone];
    record->_accessControl = [_accessControl copyWithZone:zone];
    return record;
}

#pragma mark - NSCoding

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    NSString *recordType = nil;
    NSString *recordID = nil;
    id idObj = [aDecoder decodeObjectForKey:@"recordID"];
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"
    if ([idObj isKindOfClass:[SKYRecordID class]]) {
        recordType = [(SKYRecordID *)idObj recordType];
        recordID = [(SKYRecordID *)idObj recordName];
    } else if ([idObj isKindOfClass:[NSString class]]) {
        recordID = (NSString *)idObj;
        recordType = [aDecoder decodeObjectOfClass:[NSString class] forKey:@"recordType"];
    }
#pragma GCC diagnostic pop
    if (!recordType || !recordID) {
        return nil;
    }

    NSDictionary *object = [aDecoder decodeObjectOfClass:[NSDictionary class] forKey:@"object"];
    self = [self initWithType:recordType recordID:recordID data:object];
    if (self) {
        _transient = [aDecoder decodeObjectOfClass:[NSMutableDictionary class] forKey:@"transient"];
        _ownerUserRecordID =
            [aDecoder decodeObjectOfClass:[NSString class] forKey:@"ownerUserRecordID"];
        _creationDate = [aDecoder decodeObjectOfClass:[NSDate class] forKey:@"creationDate"];
        _creatorUserRecordID =
            [aDecoder decodeObjectOfClass:[NSString class] forKey:@"creationUserRecordID"];
        _modificationDate =
            [aDecoder decodeObjectOfClass:[NSDate class] forKey:@"modificationDate"];
        _lastModifiedUserRecordID =
            [aDecoder decodeObjectOfClass:[NSString class] forKey:@"lastModifiedUserRecordID"];
        _accessControl =
            [aDecoder decodeObjectOfClass:[SKYAccessControl class] forKey:@"accessControl"];
    }

    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:_recordType forKey:@"recordType"];
    [aCoder encodeObject:_recordID forKey:@"recordID"];
    [aCoder encodeObject:_object forKey:@"object"];
    [aCoder encodeObject:_transient forKey:@"transient"];
    [aCoder encodeObject:_ownerUserRecordID forKey:@"ownerUserRecordID"];
    [aCoder encodeObject:_creationDate forKey:@"creationDate"];
    [aCoder encodeObject:_creatorUserRecordID forKey:@"creationUserRecordID"];
    [aCoder encodeObject:_modificationDate forKey:@"modificationDate"];
    [aCoder encodeObject:_lastModifiedUserRecordID forKey:@"lastModifiedUserRecordID"];
    [aCoder encodeObject:_accessControl forKey:@"accessControl"];
}

#pragma mark - Properties

- (NSDictionary *)dictionary
{
    return [_object copy];
}

#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"

- (SKYRecordID *)deprecatedID
{
    return [[SKYRecordID alloc] initWithRecordType:self.recordType name:self.recordID];
}

#pragma GCC diagnostic pop

#pragma mark - Dictionary-like methods

- (id)objectForKey:(id)key
{
    id object = [self.object objectForKey:key];
    if ([[NSNull null] isEqual:object]) {
        object = nil;
    }
    return object;
}

- (id)objectForKeyedSubscript:(id)key
{
    return [self objectForKey:key];
}

- (void)setObject:(id)object forKey:(id<NSCopying>)key
{
    if (!object) {
        object = [NSNull null];
    }
    [self.object setObject:object forKey:key];
}

- (void)setObject:(id)object forKeyedSubscript:(id<NSCopying>)key
{
    [self setObject:object forKey:key];
}

- (SKYRecord *)referencedRecordForKey:(id)key
{
    SKYReference *reference = self[key];
    return reference.record;
}

- (id)valueForKey:(NSString *)key
{
    return [self objectForKey:key];
}

- (void)setValue:(id)value forKey:(NSString *)key
{
    return [self setObject:value forKey:key];
}

@end
