//
//  ODRecordZoneID.m
//  askq
//
//  Created by Kenji Pa on 20/1/15.
//  Copyright (c) 2015 Rocky Chan. All rights reserved.
//

#import "ODRecordZoneID.h"

@implementation ODRecordZoneID

- (instancetype)initWithZoneName:(NSString *)zoneName ownerName:(NSString *)ownerName {
    self = [super init];
    if (self) {
        _zoneName = zoneName;
        _ownerName = ownerName;
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    ODRecordZoneID *recordZoneID = [[self.class allocWithZone:zone] init];
    recordZoneID->_zoneName = [_zoneName copyWithZone:zone];
    recordZoneID->_ownerName = [_ownerName copyWithZone:zone];
    return recordZoneID;
}

@end
