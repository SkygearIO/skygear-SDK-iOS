//
//  SKYUser.h
//  askq
//
//  Created by Kenji Pa on 27/1/15.
//  Copyright (c) 2015 Rocky Chan. All rights reserved.
//

#import "SKYRecord.h"

#import "SKYUserRecordID.h"

@class SKYQueryCursor;
@class SKYQueryOperation;

@interface SKYUser : NSObject

- (instancetype)init NS_UNAVAILABLE;

- (instancetype)initWithUserRecordID:(SKYUserRecordID *)recordID;

+ (instancetype)userWithUserRecordID:(SKYUserRecordID *)recordID;

/**
 * The properties username, email, authData and isNew will be delegated to
 * their corresponding methods on SKYUserRecordID
 */
@property (nonatomic, readonly, copy) NSString *username;
@property (nonatomic, readonly, copy) NSString *email;
@property (nonatomic, readonly, copy) NSDictionary *authData;
@property (nonatomic, readonly, assign) BOOL isNew;

@property (nonatomic, readonly, copy) SKYUserRecordID *recordID;

@end
