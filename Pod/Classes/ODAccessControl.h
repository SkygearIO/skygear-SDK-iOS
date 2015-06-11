//
//  ODAccessControl.h
//  Pods
//
//  Created by Kenji Pa on 9/6/15.
//
//

#import <Foundation/Foundation.h>

#import "ODRelation.h"
#import "ODUserRecordID.h"

@class ODUser;

@interface ODAccessControl : NSObject<NSFastEnumeration>

- (instancetype)init NS_UNAVAILABLE;

- (void)setPublicReadWriteAccess;

- (void)addReadAccessForUser:(ODUser *)user;
- (void)addReadAccessForUserID:(ODUserRecordID *)userID;
- (void)addReadAccessForRelation:(ODRelation *)relation;
- (void)addWriteAccessForUser:(ODUser *)user;
- (void)addWriteAccessForUserID:(ODUserRecordID *)userID;
- (void)addWriteAccessForRelation:(ODRelation *)relation;

- (void)removeReadAccessForUser:(ODUser *)user;
- (void)removeReadAccessForUserID:(ODUserRecordID *)userID;
- (void)removeReadAccessForRelation:(ODRelation *)relation;
- (void)removeWriteAccessForUser:(ODUser *)user;
- (void)removeWriteAccessForUserID:(ODUserRecordID *)userID;
- (void)removeWriteAccessForRelation:(ODRelation *)relation;

@property (nonatomic, readonly) BOOL public;

@end
