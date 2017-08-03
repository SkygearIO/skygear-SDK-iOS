//
//  SKYRecordID.m
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

#import "SKYRecordID.h"

@implementation SKYRecordID

- (instancetype)init
{
    @throw [NSException exceptionWithName:NSInvalidArgumentException
                                   reason:@"Missing Record type."
                                 userInfo:nil];
}

- (instancetype)initWithRecordType:(NSString *)type
{
    return [self initWithRecordType:type name:nil];
}

- (instancetype)initWithCanonicalString:(NSString *)canonicalString
{
    NSArray *components = [canonicalString componentsSeparatedByString:@"/"];
    if ([components count] != 2) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException
                                       reason:@"Invalid Record ID string."
                                     userInfo:nil];
    }

    return [self initWithRecordType:components[0] name:components[1]];
}

- (instancetype)initWithRecordType:(NSString *)type name:(NSString *)recordName
{
    self = [super init];
    if (self) {
        if (!type) {
            @throw [NSException exceptionWithName:NSInvalidArgumentException
                                           reason:@"Missing Record type."
                                         userInfo:nil];
        }
        _recordType = [type copy];
        _recordName = recordName ? [recordName copy] : [[NSUUID UUID] UUIDString];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    return [self initWithRecordType:[aDecoder decodeObjectOfClass:[NSString class] forKey:@"type"]
                               name:[aDecoder decodeObjectOfClass:[NSString class] forKey:@"name"]];
}

+ (BOOL)supportsSecureCoding
{
    return YES;
}

+ (instancetype)recordIDWithRecordType:(NSString *)type
{
    return [[self alloc] initWithRecordType:type];
}

+ (instancetype)recordIDWithCanonicalString:(NSString *)canonicalString
{
    NSArray *components = [canonicalString componentsSeparatedByString:@"/"];
    if ([components count] == 2) {
        return [[self alloc] initWithRecordType:components[0] name:components[1]];
    } else {
        return nil;
    }
}

+ (instancetype)recordIDWithRecordType:(NSString *)type name:(NSString *)recordName
{
    return [[self alloc] initWithRecordType:type name:recordName];
}

- (id)copyWithZone:(NSZone *)zone
{
    SKYRecordID *recordID =
        [[self.class allocWithZone:zone] initWithRecordType:[_recordType copyWithZone:zone]
                                                       name:[_recordName copyWithZone:zone]];
    return recordID;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:_recordName forKey:@"name"];
    [aCoder encodeObject:_recordType forKey:@"type"];
}

- (BOOL)isEqual:(id)object
{
    if (!object) {
        return NO;
    }

    if (![object isKindOfClass:[SKYRecordID class]]) {
        return NO;
    }

    return [self isEqualToRecordID:object];
}

- (BOOL)isEqualToRecordID:(SKYRecordID *)recordID
{
    if (!recordID) {
        return NO;
    }

    return (((recordID.recordName == nil && self.recordName == nil) ||
             [recordID.recordName isEqual:self.recordName]) &&
            ((recordID.recordType == nil && self.recordType == nil) ||
             [recordID.recordType isEqual:self.recordType]));
}

- (NSUInteger)hash
{
    return [self.recordName hash] ^ [self.recordType hash];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@: %p; recordType = %@, recordName = %@>",
                                      NSStringFromClass([self class]), self, self.recordType,
                                      self.recordName];
}

- (NSString *)canonicalString
{
    return [NSString stringWithFormat:@"%@/%@", self.recordType, self.recordName];
}

@end
