//
//  SKYGCMNotificationInfo.h
//  SkyKit
//
//  Copyright 2015 Oursky Ltd.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.

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
