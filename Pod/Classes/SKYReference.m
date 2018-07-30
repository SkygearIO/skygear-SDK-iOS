//
//  SKYReference.m
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

#import "SKYReference.h"

@interface SKYReference ()

- (instancetype)initWithCoder:(NSCoder *)decoder NS_DESIGNATED_INITIALIZER;

@end

@implementation SKYReference

- (instancetype)initWithRecord:(SKYRecord *)record
{
    if ((self = [self initWithRecordType:record.recordType recordID:record.recordID])) {
        self->_record = [record copy];
    }
    return self;
}

- (instancetype)initWithRecordType:(NSString *)recordType recordID:(NSString *)recordID
{
    if ((self = [super init])) {
        _recordType = [recordType copy];
        _recordID = [recordID copy];
    }
    return self;
}

#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"

- (instancetype)initWithRecord:(SKYRecord *)record action:(SKYReferenceAction)action
{
    return [self initWithRecord:record];
}

- (instancetype)initWithRecordID:(SKYRecordID *)recordID
{
    return [self initWithRecordType:recordID.recordType recordID:recordID.recordName];
}

- (instancetype)initWithRecordID:(SKYRecordID *)recordID action:(SKYReferenceAction)action
{
    return [self initWithRecordType:recordID.recordType recordID:recordID.recordName];
}

#pragma GCC diagnostic pop

+ (instancetype)referenceWithRecord:(SKYRecord *)record
{
    return [[self alloc] initWithRecord:record];
}

+ (instancetype)referenceWithRecordType:(NSString *)recordType recordID:(NSString *)recordID
{
    return [[self alloc] initWithRecordType:recordType recordID:recordID];
}

#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"

+ (instancetype)referenceWithRecord:(SKYRecord *)record action:(SKYReferenceAction)action
{
    return [[self alloc] initWithRecord:record action:action];
}

+ (instancetype)referenceWithRecordID:(SKYRecordID *)recordID
{
    return [[self alloc] initWithRecordType:recordID.recordType recordID:recordID.recordName];
}

+ (instancetype)referenceWithRecordID:(SKYRecordID *)recordID action:(SKYReferenceAction)action
{
    return [[self alloc] initWithRecordID:recordID];
}

#pragma GCC diagnostic pop

- (BOOL)isEqual:(id)object
{
    if (self == object) {
        return YES;
    }

    if (![object isKindOfClass:[SKYReference class]]) {
        return NO;
    }

    return [self isEqualToReference:(SKYReference *)object];
}

- (BOOL)isEqualToReference:(SKYReference *)reference
{
    return [_recordType isEqual:reference.recordType] && [_recordID isEqual:reference.recordID];
}

- (NSUInteger)hash
{
    return _recordID.hash ^ _recordType.hash;
}

#pragma NSCoding

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

    self = [super init];
    if (self) {
        _recordType = recordType;
        _recordID = recordID;
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeObject:_recordType forKey:@"recordType"];
    [encoder encodeObject:_recordID forKey:@"recordID"];
}

#pragma NSCopying

- (id)copyWithZone:(NSZone *)zone
{
    return [[SKYReference allocWithZone:zone] initWithRecordType:[self.recordType copyWithZone:zone]
                                                        recordID:[self.recordID copyWithZone:zone]];
}

#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"
#pragma GCC diagnostic ignored "-Wdeprecated-implementations"

- (SKYReferenceAction)referenceAction
{
    return SKYReferenceActionNone;
}

#pragma GCC diagnostic pop
@end
