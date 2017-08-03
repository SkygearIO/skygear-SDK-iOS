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

NS_ASSUME_NONNULL_BEGIN

/// Undocumented
@interface SKYGCMInnerNotificationInfo : NSObject <NSCopying>

/// Undocumented
@property (nonatomic, copy) NSString *_Nullable title;
/// Undocumented
@property (nonatomic, copy) NSString *_Nullable body;
/// Undocumented
@property (nonatomic, copy) NSString *_Nullable icon;
/// Undocumented
@property (nonatomic, copy) NSString *_Nullable sound;
/// Undocumented
@property (nonatomic, copy) NSString *_Nullable tag;
/// Undocumented
@property (nonatomic, copy) NSString *_Nullable clickAction;
/// Undocumented
@property (nonatomic, copy) NSString *_Nullable bodyLocKey;
/// Undocumented
@property (nonatomic, copy) NSArray *_Nullable bodyLocArgs;
/// Undocumented
@property (nonatomic, copy) NSString *_Nullable titleLocKey;
/// Undocumented
@property (nonatomic, copy) NSArray *_Nullable titleLocArgs;

/// Undocumented
- (BOOL)isEqualToNotificationInfo:(SKYGCMInnerNotificationInfo *_Nullable)notificationInfo;

@end

/// Undocumented
@interface SKYGCMNotificationInfo : NSObject <NSCopying>

/// Undocumented
+ (instancetype _Nullable)notificationInfo;

/// Undocumented
@property (nonatomic, copy) NSString *_Nullable collapseKey;
/// Undocumented
@property (nonatomic, assign) NSUInteger priority;
/// Undocumented
@property (nonatomic, assign) BOOL contentAvailable;
/// Undocumented
@property (nonatomic, assign) BOOL delayWhileIdle;
/// Undocumented
@property (nonatomic, assign) NSUInteger timeToLive;
/// Undocumented
@property (nonatomic, copy) NSString *_Nullable restrictedPackageName;

/// Undocumented
@property (nonatomic, copy) SKYGCMInnerNotificationInfo *_Nullable notification;

/// Undocumented
- (BOOL)isEqualToNotificationInfo:(SKYGCMNotificationInfo *_Nullable)notificationInfo;

@end

NS_ASSUME_NONNULL_END
