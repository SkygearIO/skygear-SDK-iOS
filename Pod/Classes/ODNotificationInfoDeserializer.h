//
//  ODNotificationInfoDeserializer.h
//  Pods
//
//  Created by Kenji Pa on 15/5/15.
//
//

#import <Foundation/Foundation.h>

#import "ODNotificationInfo.h"

@interface ODNotificationInfoDeserializer : NSObject

+ (instancetype)deserializer;

- (ODNotificationInfo *)notificationInfoWithDictionary:(NSDictionary *)dictionary;

@end
