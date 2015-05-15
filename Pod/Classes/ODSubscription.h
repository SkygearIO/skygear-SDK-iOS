//
//  ODSubscription.h
//  askq
//
//  Created by Kenji Pa on 29/1/15.
//  Copyright (c) 2015 Rocky Chan. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ODNotificationInfo.h"
#import "ODQuery.h"

@interface ODSubscription : NSObject

- (instancetype)initWithQuery:(ODQuery *)query;
- (instancetype)initWithQuery:(ODQuery *)query
                 subscriptionID:(NSString *)subscriptionID;

- (instancetype)initWithRecordType:(NSString *)recordType
                         predicate:(NSPredicate *)predicate;
- (instancetype)initWithRecordType:(NSString *)recordType
                         predicate:(NSPredicate *)predicate
                    subscriptionID:(NSString *)subscriptionID;

@property (nonatomic, readonly) ODQuery *query;

// probably duplicated with query?
@property (nonatomic, readonly, copy) NSString *recordType;
@property (nonatomic, readonly, copy) NSPredicate *predicate;

@property(nonatomic, copy) ODNotificationInfo *notificationInfo;

@property (nonatomic, readonly, copy) NSString *subscriptionID;

@end
