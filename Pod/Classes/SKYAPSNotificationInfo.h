//
//  SKYAPSNotificationInfo.h
//  Pods
//
//  Created by Kenji Pa on 11/11/2015.
//
//

#import <Foundation/Foundation.h>

@interface SKYAPSNotificationInfo : NSObject <NSCopying>

+ (instancetype)notificationInfo;

@property (nonatomic, copy) NSString *alertBody;
@property (nonatomic, copy) NSString *alertLocalizationKey;
@property (nonatomic, copy) NSArray *alertLocalizationArgs;
@property (nonatomic, copy) NSString *alertActionLocalizationKey;
@property (nonatomic, copy) NSString *alertLaunchImage;
@property (nonatomic, copy) NSString *soundName;
@property (nonatomic, assign) BOOL shouldBadge;
@property (nonatomic, assign) BOOL shouldSendContentAvailable;

- (BOOL)isEqualToNotificationInfo:(SKYAPSNotificationInfo *)notificationInfo;

@end
