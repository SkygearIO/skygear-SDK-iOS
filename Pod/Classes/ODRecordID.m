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
    return [self initWithRecordName:[[NSUUID UUID] UUIDString]
                             zoneID:nil];
}

- (instancetype)initWithRecordName:(NSString *)recordName {
    return [self initWithRecordName:recordName zoneID:nil];
}

- (instancetype)initWithRecordName:(NSString *)recordName zoneID:(ODRecordZoneID *)zoneID {
    self = [super init];
    if (self) {
        _recordName = recordName;
        _zoneID = zoneID;
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    ODRecordID *recordID = [[self.class allocWithZone:zone] init];
    recordID->_recordName = [_recordName copyWithZone:zone];
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
            );
}

- (NSUInteger)hash
{
    return [self.recordName hash] ^ [self.zoneID hash];
}
@end
