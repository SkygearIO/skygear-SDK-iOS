//
//  SKYGCMNotificationInfo.h
//  Pods
//
//  Created by Kenji Pa on 12/11/2015.
//
//

#import <Foundation/Foundation.h>

@interface SKYGCMInnerNotificationInfo : NSObject <NSCopying>

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *body;
@property (nonatomic, copy) NSString *icon;
@property (nonatomic, copy) NSString *sound;
@property (nonatomic, copy) NSString *tag;
@property (nonatomic, copy) NSString *clickAction;
@property (nonatomic, copy) NSString *bodyLocKey;
@property (nonatomic, copy) NSArray *bodyLocArgs;
@property (nonatomic, copy) NSString *titleLocKey;
@property (nonatomic, copy) NSArray *titleLocArgs;

- (BOOL)isEqualToNotificationInfo:(SKYGCMInnerNotificationInfo *)notificationInfo;

@end

@interface SKYGCMNotificationInfo : NSObject <NSCopying>

+ (instancetype)notificationInfo;

@property (nonatomic, copy) NSString *collapseKey;
@property (nonatomic, assign) NSUInteger priority;
@property (nonatomic, assign) BOOL contentAvailable;
@property (nonatomic, assign) BOOL delayWhileIdle;
@property (nonatomic, assign) NSUInteger timeToLive;
@property (nonatomic, copy) NSString *restrictedPackageName;

@property (nonatomic, copy) SKYGCMInnerNotificationInfo *notification;

- (BOOL)isEqualToNotificationInfo:(SKYGCMNotificationInfo *)notificationInfo;

@end
