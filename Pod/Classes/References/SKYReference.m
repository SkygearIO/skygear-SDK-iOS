//
//  SKYReference.m
//  askq
//
//  Created by Kenji Pa on 20/1/15.
//  Copyright (c) 2015 Rocky Chan. All rights reserved.
//

#import "SKYReference.h"

@interface SKYReference()

- (instancetype)initWithCoder:(NSCoder *)decoder NS_DESIGNATED_INITIALIZER;
- (instancetype)initWithRecordID:(SKYRecordID *)recordID referencedRecord:(SKYRecord *)record action:(SKYReferenceAction)action NS_DESIGNATED_INITIALIZER;

@end

@implementation SKYReference

- (instancetype)initWithRecord:(SKYRecord *)record {
    return [self initWithRecord:record action:SKYReferenceActionNone];
}

- (instancetype)initWithRecord:(SKYRecord *)record action:(SKYReferenceAction)action {
    return [self initWithRecordID:record.recordID referencedRecord:record action:action];
}

- (instancetype)initWithRecordID:(SKYRecordID *)recordID {
    return [self initWithRecordID:recordID action:SKYReferenceActionNone];
}

- (instancetype)initWithRecordID:(SKYRecordID *)recordID action:(SKYReferenceAction)action {
    return [self initWithRecordID:recordID referencedRecord:nil action:action];
}

- (instancetype)initWithRecordID:(SKYRecordID *)recordID referencedRecord:(SKYRecord *)record action:(SKYReferenceAction)action {
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

- (BOOL)isEqual:(id)object {
    if (self == object) {
        return YES;
    }

    if (![object isKindOfClass:[SKYReference class]]) {
        return NO;
    }

    return [self isEqualToReference:(SKYReference *)object];
}

- (BOOL)isEqualToReference:(SKYReference *)reference {
    return [_recordID isEqualToRecordID:reference.recordID] && _referenceAction == reference.referenceAction;
}

- (NSUInteger)hash {
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
