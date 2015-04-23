//
//  ODReference.m
//  askq
//
//  Created by Kenji Pa on 20/1/15.
//  Copyright (c) 2015 Rocky Chan. All rights reserved.
//

#import "ODReference.h"

@interface ODReference()

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

@end
