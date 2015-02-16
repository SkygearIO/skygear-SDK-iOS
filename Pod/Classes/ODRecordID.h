//
//  ODRecordID.h
//  askq
//
//  Created by Kenji Pa on 20/1/15.
//  Copyright (c) 2015 Rocky Chan. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ODRecordZoneID.h"

@interface ODRecordID : NSObject<NSCopying>

- (instancetype)initWithRecordName:(NSString *)recordName;
- (instancetype)initWithRecordName:(NSString *)recordName zoneID:(ODRecordZoneID *)zoneID NS_DESIGNATED_INITIALIZER;

@property(nonatomic, readonly, strong) NSString *recordName;
@property(nonatomic, readonly, strong) ODRecordZoneID *zoneID;

@end
