//
//  SKYUserRecordID_Private.h
//  askq
//
//  Created by Kenji Pa on 30/1/15.
//  Copyright (c) 2015 Rocky Chan. All rights reserved.
//

#import "SKYUserRecordID.h"

@interface SKYUserRecordID()

- (instancetype)initWithUsername:(NSString *)username;
- (instancetype)initWithUsername:(NSString *)username email:(NSString *)email;
- (instancetype)initWithUsername:(NSString *)username email:(NSString *)email authData:(NSDictionary *)authData NS_DESIGNATED_INITIALIZER;

+ (instancetype)recordIDWithUsername:(NSString *)username;
+ (instancetype)recordIDWithUsername:(NSString *)username email:(NSString *)email;
+ (instancetype)recordIDWithUsername:(NSString *)username email:(NSString *)email authData:(NSDictionary *)authData;

@end
