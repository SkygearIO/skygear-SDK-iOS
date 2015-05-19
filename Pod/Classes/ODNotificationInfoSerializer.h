//
//  ODNotificationInfoSerializer.h
//  Pods
//
//  Created by Kenji Pa on 14/5/15.
//
//

#import <Foundation/Foundation.h>

#import "ODNotificationInfo.h"

@interface ODNotificationInfoSerializer : NSObject

+ (instancetype)serializer;

- (NSDictionary *)dictionaryWithNotificationInfo:(ODNotificationInfo *)notificationInfo;

@end
