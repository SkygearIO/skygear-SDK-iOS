//
//  SKYNotificationInfoSerializer.h
//  Pods
//
//  Created by Kenji Pa on 14/5/15.
//
//

#import <Foundation/Foundation.h>

#import "SKYNotificationInfo.h"

@interface SKYNotificationInfoSerializer : NSObject

+ (instancetype)serializer;

- (NSDictionary *)dictionaryWithNotificationInfo:(SKYNotificationInfo *)notificationInfo;

@end
