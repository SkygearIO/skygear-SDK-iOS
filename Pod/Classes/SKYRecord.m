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

@interface SKYRecord ()

@property (nonatomic, readonly) NSMutableDictionary *object;

@end

@implementation SKYRecord

- (instancetype)initWithRecordType:(NSString *)recordType
{
    return [self initWithRecordID:[[SKYRecordID alloc] initWithRecordType:recordType] data:nil];
}

- (instancetype)initWithRecordType:(NSString *)recordType recordID:(SKYRecordID *)recordId
{
    if (![recordId.recordType isEqualToString:recordId.recordType]) {
        recordId = [[SKYRecordID alloc] initWithRecordType:recordType name:recordId.recordName];
    }
    return [self initWithRecordID:recordId data:nil];
}

- (instancetype)initWithRecordType:(NSString *)recordType name:(NSString *)recordName
{
    return
        [self initWithRecordID:[[SKYRecordID alloc] initWithRecordType:recordType name:recordName]
                          data:nil];
}

- (instancetype)initWithRecordType:(NSString *)recordType
                          recordID:(SKYRecordID *)recordId
                              data:(NSDictionary *)data
{
    if (![recordId.recordType isEqualToString:recordId.recordType]) {
        recordId = [[SKYRecordID alloc] initWithRecordType:recordType name:recordId.recordName];
    }
    return [self initWithRecordID:recordId data:data];
}

- (instancetype)initWithRecordType:(NSString *)recordType
                              name:(NSString *)recordName
                              data:(NSDictionary *)data
{
    return
        [self initWithRecordID:[[SKYRecordID alloc] initWithRecordType:recordType name:recordName]
                          data:data];
}

- (instancetype)initWithRecordID:(SKYRecordID *)recordId data:(NSDictionary *)data
{
    self = [super init];
    if (self) {
        _recordID = [recordId copy];
        _object = data ? [data mutableCopy] : [[NSMutableDictionary alloc] init];
        _accessControl = nil;
        _transient = [NSMutableDictionary dictionary];
    }
    return self;
}

+ (instancetype)recordWithRecordType:(NSString *)recordType
{
    return [[self alloc] initWithRecordType:recordType];
}

+ (instancetype)recordWithRecordType:(NSString *)recordType name:(NSString *)recordName
{
    return [[self alloc] initWithRecordType:recordType name:recordName];
}

+ (instancetype)recordWithRecordType:(NSString *)recordType
                                name:(NSString *)recordName
                                data:(NSDictionary *)data
{
    return [[self alloc] initWithRecordType:recordType name:recordName data:data];
}

+ (instancetype)recordWithRecordID:(SKYRecordID *)recordId data:(NSDictionary *)data
{
    return [[self alloc] initWithRecordID:recordId data:data];
}

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone
{
    SKYRecord *record = [[self.class allocWithZone:zone] init];
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
    SKYRecordID *recordID = [aDecoder decodeObjectOfClass:[SKYRecordID class] forKey:@"recordID"];
    if (!recordID) {
        return nil;
    }

    NSDictionary *object = [aDecoder decodeObjectOfClass:[NSDictionary class] forKey:@"object"];
    self = [self initWithRecordID:recordID data:object];
    if (self) {
        _transient = [aDecoder decodeObjectOfClass:[NSMutableDictionary class] forKey:@"transient"];
        _ownerUserRecordID =
            [aDecoder decodeObjectOfClass:[SKYRecordID class] forKey:@"ownerUserRecordID"];
        _creationDate = [aDecoder decodeObjectOfClass:[NSDate class] forKey:@"creationDate"];
        _creatorUserRecordID =
            [aDecoder decodeObjectOfClass:[SKYRecordID class] forKey:@"creationUserRecordID"];
        _modificationDate =
            [aDecoder decodeObjectOfClass:[NSDate class] forKey:@"modificationDate"];
        _lastModifiedUserRecordID =
            [aDecoder decodeObjectOfClass:[SKYRecordID class] forKey:@"lastModifiedUserRecordID"];
        _accessControl =
            [aDecoder decodeObjectOfClass:[SKYAccessControl class] forKey:@"accessControl"];
    }

    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
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

- (void)setRecordID:(SKYRecordID *)recordID
{
    _recordID = recordID;
}

- (void)setCreationDate:(NSDate *)date
{
    _creationDate = date;
}

- (NSDictionary *)dictionary
{
    return [_object copy];
}

- (NSString *)recordType
{
    return self.recordID.recordType;
}

- (void)setAccessControl:(SKYAccessControl *)accessControl
{
    _accessControl = accessControl;
}

- (SKYAccessControl *)getAccessControl
{
    if (_accessControl == nil) {
        _accessControl = [SKYAccessControl emptyAccessControl];
    }
    return _accessControl;
}

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
