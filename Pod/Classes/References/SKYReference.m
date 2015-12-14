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
- (instancetype)initWithRecordID:(SKYRecordID *)recordID
                referencedRecord:(SKYRecord *)record
                          action:(SKYReferenceAction)action NS_DESIGNATED_INITIALIZER;

@end

@implementation SKYReference

- (instancetype)initWithRecord:(SKYRecord *)record
{
    return [self initWithRecord:record action:SKYReferenceActionNone];
}

- (instancetype)initWithRecord:(SKYRecord *)record action:(SKYReferenceAction)action
{
    return [self initWithRecordID:record.recordID referencedRecord:record action:action];
}

- (instancetype)initWithRecordID:(SKYRecordID *)recordID
{
    return [self initWithRecordID:recordID action:SKYReferenceActionNone];
}

- (instancetype)initWithRecordID:(SKYRecordID *)recordID action:(SKYReferenceAction)action
{
    return [self initWithRecordID:recordID referencedRecord:nil action:action];
}

- (instancetype)initWithRecordID:(SKYRecordID *)recordID
                referencedRecord:(SKYRecord *)record
                          action:(SKYReferenceAction)action
{
    self = [super init];
    if (self) {
        _record = record;
        _recordID = recordID;
        _referenceAction = action;
    }
    return self;
}

+ (instancetype)referenceWithRecord:(SKYRecord *)record
{
    return [[self alloc] initWithRecord:record];
}

+ (instancetype)referenceWithRecord:(SKYRecord *)record action:(SKYReferenceAction)action
{
    return [[self alloc] initWithRecord:record action:action];
}

+ (instancetype)referenceWithRecordID:(SKYRecordID *)recordID
{
    return [[self alloc] initWithRecordID:recordID];
}

+ (instancetype)referenceWithRecordID:(SKYRecordID *)recordID action:(SKYReferenceAction)action
{
    return [[self alloc] initWithRecordID:recordID action:action];
}

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
    return [_recordID isEqualToRecordID:reference.recordID] &&
           _referenceAction == reference.referenceAction;
}

- (NSUInteger)hash
{
    return _recordID.hash ^ _referenceAction;
}

#pragma NSCoding

- (instancetype)initWithCoder:(NSCoder *)decoder
{
    SKYRecordID *recordID = [decoder decodeObjectForKey:@"recordID"];
    SKYReferenceAction action = [decoder decodeIntegerForKey:@"referenceAction"];
    self = [super init];
    if (self) {
        _recordID = recordID;
        _referenceAction = action;
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeObject:_recordID forKey:@"recordID"];
    [encoder encodeInteger:_referenceAction forKey:@"referenceAction"];
}

@end
