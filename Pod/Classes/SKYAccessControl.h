//
//  SKYAccessControl.h
//  Pods
//
//  Created by Kenji Pa on 9/6/15.
//
//

#import <Foundation/Foundation.h>

#import "SKYRelation.h"
#import "SKYUserRecordID.h"

@class SKYUser;

@interface SKYAccessControl : NSObject<NSFastEnumeration>

- (instancetype)init NS_UNAVAILABLE;

- (void)setPublicReadWriteAccess;

- (void)addReadAccessForUser:(SKYUser *)user;
- (void)addReadAccessForUserID:(SKYUserRecordID *)userID;
- (void)addReadAccessForRelation:(SKYRelation *)relation;
- (void)addWriteAccessForUser:(SKYUser *)user;
- (void)addWriteAccessForUserID:(SKYUserRecordID *)userID;
- (void)addWriteAccessForRelation:(SKYRelation *)relation;

- (void)removeReadAccessForUser:(SKYUser *)user;
- (void)removeReadAccessForUserID:(SKYUserRecordID *)userID;
- (void)removeReadAccessForRelation:(SKYRelation *)relation;
- (void)removeWriteAccessForUser:(SKYUser *)user;
- (void)removeWriteAccessForUserID:(SKYUserRecordID *)userID;
- (void)removeWriteAccessForRelation:(SKYRelation *)relation;

@property (nonatomic, readonly) BOOL public;

@end
