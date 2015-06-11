//
//  ODAccessControlEntry.h
//  Pods
//
//  Created by Kenji Pa on 9/6/15.
//
//

#import <Foundation/Foundation.h>

#import "ODRelation.h"
#import "ODUser.h"
#import "ODUserRecordID.h"

typedef enum : NSUInteger {
    ODAccessControlEntryLevelRead = 0,
    ODAccessControlEntryLevelWrite = 1,
} ODAccessControlEntryLevel;

typedef enum : NSUInteger {
    ODAccessControlEntryTypeRelation = 0,
    ODAccessControlEntryTypeDirect = 1,
} ODAccessControlEntryType;

NSString * NSStringFromAccessControlEntryLevel(ODAccessControlEntryLevel);

// NOTE(limouren): this class is consider an implementation details of ODAccessControl
@interface ODAccessControlEntry : NSObject

+ (instancetype)readEntryForUser:(ODUser *)user;
+ (instancetype)readEntryForUserID:(ODUserRecordID *)user;
+ (instancetype)readEntryForRelation:(ODRelation *)relation;

+ (instancetype)writeEntryForUser:(ODUser *)user;
+ (instancetype)writeEntryForUserID:(ODUserRecordID *)user;
+ (instancetype)writeEntryForRelation:(ODRelation *)relation;

- (instancetype)init NS_UNAVAILABLE;

@property (nonatomic, readonly, assign) ODAccessControlEntryType entryType;
@property (nonatomic, readonly, assign) ODAccessControlEntryLevel accessLevel;
@property (nonatomic, readonly) ODRelation *relation;
@property (nonatomic, copy, readonly) ODUserRecordID *userID;

@end
