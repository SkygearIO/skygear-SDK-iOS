//
//  ODReference.m
//  askq
//
//  Created by Kenji Pa on 20/1/15.
//  Copyright (c) 2015 Rocky Chan. All rights reserved.
//

#import "ODReference.h"

@interface ODReference()

- (instancetype)initWithCoder:(NSCoder *)decoder NS_DESIGNATED_INITIALIZER;
- (instancetype)initWithRecordID:(ODRecordID *)recordID referencedRecord:(ODRecord *)record action:(ODReferenceAction)action NS_DESIGNATED_INITIALIZER;

@end

@implementation ODReference

- (instancetype)initWithRecord:(ODRecord *)record {
    return [self initWithRecord:record action:ODReferenceActionNone];
}

- (instancetype)initWithRecord:(ODRecord *)record action:(ODReferenceAction)action {
    return [self initWithRecordID:record.recordID referencedRecord:record action:action];
}

- (instancetype)initWithRecordID:(ODRecordID *)recordID {
    return [self initWithRecordID:recordID action:ODReferenceActionNone];
}

- (instancetype)initWithRecordID:(ODRecordID *)recordID action:(ODReferenceAction)action {
    return [self initWithRecordID:recordID referencedRecord:nil action:action];
}

- (instancetype)initWithRecordID:(ODRecordID *)recordID referencedRecord:(ODRecord *)record action:(ODReferenceAction)action {
    self = [super init];
    if (self) {
        _record = record;
        _recordID = recordID;
        _referenceAction = action;
    }
    return self;
}

+ (instancetype)referenceWithRecord:(ODRecord *)record
{
    return [[self alloc] initWithRecord:record];
}

+ (instancetype)referenceWithRecord:(ODRecord *)record action:(ODReferenceAction)action
{
    return [[self alloc] initWithRecord:record action:action];
}

+ (instancetype)referenceWithRecordID:(ODRecordID *)recordID
{
    return [[self alloc] initWithRecordID:recordID];
}

+ (instancetype)referenceWithRecordID:(ODRecordID *)recordID action:(ODReferenceAction)action
{
    return [[self alloc] initWithRecordID:recordID action:action];
}

- (BOOL)isEqual:(id)object {
    if (self == object) {
        return YES;
    }

    if (![object isKindOfClass:[ODReference class]]) {
        return NO;
    }

    return [self isEqualToReference:(ODReference *)object];
}

- (BOOL)isEqualToReference:(ODReference *)reference {
    return [_recordID isEqualToRecordID:reference.recordID] && _referenceAction == reference.referenceAction;
}

- (NSUInteger)hash {
    return _recordID.hash ^ _referenceAction;
}

#pragma NSCoding

- (instancetype)initWithCoder:(NSCoder *)decoder
{
    ODRecordID *recordID = [decoder decodeObjectForKey:@"recordID"];
    ODReferenceAction action = [decoder decodeIntegerForKey:@"referenceAction"];
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
