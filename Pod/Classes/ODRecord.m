//
//  ODRecord.m
//  askq
//
//  Created by Kenji Pa on 16/1/15.
//  Copyright (c) 2015 Rocky Chan. All rights reserved.
//

#import "ODRecord.h"

#import "ODReference.h"

@interface ODRecord()

@property (nonatomic, readonly) NSMutableDictionary *object;

@end

@implementation ODRecord

- (instancetype)initWithRecordType:(NSString *)recordType {
    return [self initWithRecordID:[[ODRecordID alloc] initWithRecordType:recordType]
                             data:nil];
}

- (instancetype)initWithRecordType:(NSString *)recordType recordID:(ODRecordID *)recordId {
    if (![recordId.recordType isEqualToString:recordId.recordType]) {
        recordId = [[ODRecordID alloc] initWithRecordType:recordType name:recordId.recordName];
    }
    return [self initWithRecordID:recordId data:nil];
}

- (instancetype)initWithRecordType:(NSString *)recordType name:(NSString *)recordName
{
    return [self initWithRecordID:[[ODRecordID alloc] initWithRecordType:recordType name:recordName]
                             data:nil];
}

- (instancetype)initWithRecordType:(NSString *)recordType recordID:(ODRecordID *)recordId data:(NSDictionary *)data
{
    if (![recordId.recordType isEqualToString:recordId.recordType]) {
        recordId = [[ODRecordID alloc] initWithRecordType:recordType name:recordId.recordName];
    }
    return [self initWithRecordID:recordId data:data];
}

- (instancetype)initWithRecordType:(NSString *)recordType name:(NSString *)recordName data:(NSDictionary *)data
{
    return [self initWithRecordID:[[ODRecordID alloc] initWithRecordType:recordType name:recordName]
                             data:data];
}

- (instancetype)initWithRecordID:(ODRecordID *)recordId data:(NSDictionary *)data
{
    self = [super init];
    if (self) {
        _recordID = [recordId copy];
        _object = data ? [data mutableCopy] : [[NSMutableDictionary alloc] init];
    }
    return self;
}


#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone {
    ODRecord *record = [[self.class allocWithZone:zone] init];
    record->_recordID = [_recordID copyWithZone:zone];
    record->_object = [[_object copyWithZone:zone] mutableCopy];
    return record;
}

#pragma mark - Properties

- (void)setRecordID:(ODRecordID *)recordID {
    _recordID = recordID;
}

- (void)setCreationDate:(NSDate *)date {
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

#pragma mark - Dictionary-like methods

- (id)objectForKey:(id)key {
    id object = [self.object objectForKey:key];
    if ([[NSNull null] isEqual:object]) {
        object = nil;
    }
    return object;
}

- (id)objectForKeyedSubscript:(id)key {
    return [self objectForKey:key];
}

- (void)setObject:(id)object forKey:(id <NSCopying>)key {
    if (!object) {
        object = [NSNull null];
    }
    [self.object setObject:object forKey:key];
}

- (void)setObject:(id)object forKeyedSubscript:(id <NSCopying>)key {
    [self setObject:object forKey:key];
}

- (ODRecord *)referencedRecordForKey:(id)key {
    ODReference *reference = self[key];
    return reference.record;
}

#pragma mark - Atomic increment

- (void)incrementKey:(id<NSCopying>)key {
    // nothing
}

- (void)incrementKey:(id<NSCopying>)key amount:(NSInteger)amount {
    // nothing
}

- (void)incrementKeyPath:(id<NSCopying>)keyPath {
    // nothing
}

- (void)incrementKeyPath:(id<NSCopying>)keyPath amount:(NSInteger)amount {
    // nothing
}
    
@end
