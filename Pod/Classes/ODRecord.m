//
//  ODRecord.m
//  askq
//
//  Created by Kenji Pa on 16/1/15.
//  Copyright (c) 2015 Rocky Chan. All rights reserved.
//

#import "ODRecord.h"

@interface ODRecord()

@property (nonatomic, readonly) NSMutableDictionary *object;

@end

@implementation ODRecord

- (instancetype)initWithRecordType:(NSString *)recordType {
    return [self initWithRecordType:recordType recordID:nil];
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


- (void)setRecordID:(ODRecordID *)recordID {
    _recordID = recordID;
}

- (void)setCreationDate:(NSDate *)date {
    _creationDate = date;
}

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

- (NSDictionary *)dictionary
{
    return [_object copy];
}

@end
