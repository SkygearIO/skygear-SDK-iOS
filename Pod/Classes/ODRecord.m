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
    return [self initWithRecordType:recordType
                           recordID:[[ODRecordID alloc] init]];
}

- (instancetype)initWithRecordType:(NSString *)recordType recordID:(ODRecordID *)recordId {
    self = [super init];
    if (self) {
        _recordType = recordType;
        _recordID = recordId;
        _object = [NSMutableDictionary dictionary];
    }
    return self;
}

- (instancetype)initWithRecordType:(NSString *)recordType recordID:(ODRecordID *)recordId data:(NSDictionary *)data
{
    self = [super init];
    if (self) {
        _recordType = recordType;
        _recordID = recordId;
        _object = [data mutableCopy];
    }
    return self;
}

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone {
    ODRecord *record = [[self.class allocWithZone:zone] init];
    record->_recordType = [_recordType copyWithZone:zone];
    record->_recordID = [_recordID copyWithZone:zone];
    record->_object = [_object copyWithZone:zone];
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

#pragma mark - Dictionary-like methods

- (id)objectForKey:(id)key {
    return [self.object objectForKey:key];
}

- (id)objectForKeyedSubscript:(id)key {
    return [self objectForKey:key];
}

- (void)setObject:(id)object forKey:(id <NSCopying>)key {
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
