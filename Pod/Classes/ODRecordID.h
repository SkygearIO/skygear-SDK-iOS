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

/**
 Instantiates an instance of ODRecordID with a random record name and the default record zone.
 */
- (instancetype)init __deprecated;
- (instancetype)initWithRecordName:(NSString *)recordName __deprecated;
- (instancetype)initWithRecordName:(NSString *)recordName zoneID:(ODRecordZoneID *)zoneID __deprecated;

- (instancetype)initWithRecordType:(NSString *)type;
- (instancetype)initWithCanonicalString:(NSString *)canonicalString;
- (instancetype)initWithRecordType:(NSString *)type name:(NSString *)recordName NS_DESIGNATED_INITIALIZER;

+ (instancetype)recordIDWithCanonicalString:(NSString *)canonicalString;

@property(nonatomic, readonly, strong) NSString *recordType;
@property(nonatomic, readonly, strong) NSString *recordName;
@property(nonatomic, readonly, strong) ODRecordZoneID *zoneID;
@property(nonatomic, readonly, strong) NSString *canonicalString;

@end
