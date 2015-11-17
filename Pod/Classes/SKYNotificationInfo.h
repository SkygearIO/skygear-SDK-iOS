//
//  SKYNotificationInfo.h
//  askq
//
//  Created by Kenji Pa on 29/1/15.
//  Copyright (c) 2015 Rocky Chan. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SKYAPSNotificationInfo.h"
#import "SKYGCMNotificationInfo.h"

@interface SKYNotificationInfo : NSObject <NSCopying>

+ (instancetype)notificationInfo;

@property (nonatomic, copy) SKYAPSNotificationInfo *apsNotificationInfo;
@property (nonatomic, copy) SKYGCMNotificationInfo *gcmNotificationInfo;

@property (nonatomic, copy) NSArray *desiredKeys;

- (BOOL)isEqualToNotificationInfo:(SKYNotificationInfo *)notificationInfo;

@end
