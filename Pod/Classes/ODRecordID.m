//
//  ODRecordID.m
//  askq
//
//  Created by Kenji Pa on 20/1/15.
//  Copyright (c) 2015 Rocky Chan. All rights reserved.
//

#import "ODRecordID.h"

@implementation ODRecordID

- (instancetype)init
{
    return [self initWithRecordType:nil name:nil];
}

- (instancetype)initWithRecordName:(NSString *)recordName {
    return [self initWithRecordType:nil name:recordName];
}

- (instancetype)initWithRecordName:(NSString *)recordName zoneID:(ODRecordZoneID *)zoneID {
    self = [self initWithRecordType:nil name:recordName];
    if (self) {
        self->_zoneID = zoneID;
    }
    return self;
}

- (instancetype)initWithRecordType:(NSString *)type
{
    return [self initWithRecordType:type name:nil];
}

- (instancetype)initWithRecordType:(NSString *)type name:(NSString *)recordName
{
    self = [super init];
    if (self) {
        if (!type) {
            NSLog(@"Deprecation Warning: %@ created without record type.", NSStringFromClass([self class]));
        }
        _recordType = [type copy];
        _recordName = recordName ? [recordName copy] : [[NSUUID UUID] UUIDString];
        _zoneID = nil;
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    ODRecordID *recordID = [[self.class allocWithZone:zone] initWithRecordType:[_recordType copyWithZone:zone]
                                                                          name:[_recordName copyWithZone:zone]];
    recordID->_zoneID = [_zoneID copyWithZone:zone];
    return recordID;
}

- (BOOL)isEqual:(id)object
{
    if (!object) {
        return NO;
    }
    
    if (![object isKindOfClass:[ODRecordID class]]) {
        return NO;
    }
    
    return [self isEqualToRecordID:object];
}

- (BOOL)isEqualToRecordID:(ODRecordID *)recordID
{
    if (!recordID) {
        return NO;
    }
    
    return (
            ((recordID.recordName == nil && self.recordName == nil) || [recordID.recordName isEqual:self.recordName])
            && ((recordID.zoneID == nil && self.zoneID == nil) || [recordID.zoneID isEqual:self.zoneID])
            && ((recordID.recordType == nil && self.recordType == nil) || [recordID.recordType isEqual:self.recordType])
            );
}

- (NSUInteger)hash
{
    return [self.recordName hash] ^ [self.zoneID hash] ^ [self.recordType hash];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@: %p; recordType = %@, recordName = %@>",
            NSStringFromClass([self class]), self, self.recordType, self.recordName];
}

- (NSString *)canonicalString
{
    return [NSString stringWithFormat:@"%@/%@", self.recordType, self.recordName];
}

@end
