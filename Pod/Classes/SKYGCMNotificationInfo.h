//
//  SKYGCMNotificationInfo.h
//  SKYKit
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
//

#import <Foundation/Foundation.h>

/// Undocumented
@interface SKYGCMInnerNotificationInfo : NSObject <NSCopying>

/// Undocumented
@property (nonatomic, copy) NSString *title;
/// Undocumented
@property (nonatomic, copy) NSString *body;
/// Undocumented
@property (nonatomic, copy) NSString *icon;
/// Undocumented
@property (nonatomic, copy) NSString *sound;
/// Undocumented
@property (nonatomic, copy) NSString *tag;
/// Undocumented
@property (nonatomic, copy) NSString *clickAction;
/// Undocumented
@property (nonatomic, copy) NSString *bodyLocKey;
/// Undocumented
@property (nonatomic, copy) NSArray *bodyLocArgs;
/// Undocumented
@property (nonatomic, copy) NSString *titleLocKey;
/// Undocumented
@property (nonatomic, copy) NSArray *titleLocArgs;

/// Undocumented
- (BOOL)isEqualToNotificationInfo:(SKYGCMInnerNotificationInfo *)notificationInfo;

@end

/// Undocumented
@interface SKYGCMNotificationInfo : NSObject <NSCopying>

/// Undocumented
+ (instancetype)notificationInfo;

/// Undocumented
@property (nonatomic, copy) NSString *collapseKey;
/// Undocumented
@property (nonatomic, assign) NSUInteger priority;
/// Undocumented
@property (nonatomic, assign) BOOL contentAvailable;
/// Undocumented
@property (nonatomic, assign) BOOL delayWhileIdle;
/// Undocumented
@property (nonatomic, assign) NSUInteger timeToLive;
/// Undocumented
@property (nonatomic, copy) NSString *restrictedPackageName;

/// Undocumented
@property (nonatomic, copy) SKYGCMInnerNotificationInfo *notification;

/// Undocumented
- (BOOL)isEqualToNotificationInfo:(SKYGCMNotificationInfo *)notificationInfo;

@end
