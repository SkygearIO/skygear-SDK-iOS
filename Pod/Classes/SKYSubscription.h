//
//  SKYSubscription.h
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

#import "SKYNotificationInfo.h"
#import "SKYQuery.h"

/// Undocumented
typedef enum : NSInteger {
    SKYSubscriptionTypeQuery = 1,
    SKYSubscriptionTypeRecordZone = 2,
} SKYSubscriptionType;

/// Undocumented
@interface SKYSubscription : NSObject

/// Undocumented
- (instancetype)initWithQuery:(SKYQuery *)query;
/// Undocumented
- (instancetype)initWithQuery:(SKYQuery *)query subscriptionID:(NSString *)subscriptionID;

/// Undocumented
+ (instancetype)subscriptionWithQuery:(SKYQuery *)query;
/// Undocumented
+ (instancetype)subscriptionWithQuery:(SKYQuery *)query subscriptionID:(NSString *)subscriptionID;

/// Undocumented
@property (nonatomic, readonly, assign) SKYSubscriptionType subscriptionType;

/// Undocumented
@property (nonatomic, readonly) SKYQuery *query;

// probably duplicated with query?
/// Undocumented
@property (nonatomic, readonly, copy) NSString *recordType;
/// Undocumented
@property (nonatomic, readonly, copy) NSPredicate *predicate;

/// Undocumented
@property (nonatomic, copy) SKYNotificationInfo *notificationInfo;

/// Undocumented
@property (nonatomic, readonly, copy) NSString *subscriptionID;

@end
