//
//  SKYNotificationInfoDeserializer.h
//  Pods
//
//  Created by Kenji Pa on 15/5/15.
//
//

#import <Foundation/Foundation.h>

#import "SKYNotificationInfo.h"

@interface SKYNotificationInfoDeserializer : NSObject

+ (instancetype)deserializer;

- (SKYNotificationInfo *)notificationInfoWithDictionary:(NSDictionary *)dictionary;

@end
