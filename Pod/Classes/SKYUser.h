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

@interface SKYUser : SKYRecord

- (instancetype)initWithUserRecordID:(SKYUserRecordID *)recordID;
- (instancetype)initWithUserRecordID:(SKYUserRecordID *)recordID
                                data:(NSDictionary *)data NS_DESIGNATED_INITIALIZER;

- (instancetype)initWithRecordType:(NSString *)recordType NS_UNAVAILABLE;
- (instancetype)initWithRecordType:(NSString *)recordType
                              name:(NSString *)recordName NS_UNAVAILABLE;
- (instancetype)initWithRecordType:(NSString *)recordType
                          recordID:(SKYRecordID *)recordId NS_UNAVAILABLE;
- (instancetype)initWithRecordType:(NSString *)recordType
                          recordID:(SKYRecordID *)recordId
                              data:(NSDictionary *)data NS_UNAVAILABLE;
- (instancetype)initWithRecordType:(NSString *)recordType
                              name:(NSString *)recordName
                              data:(NSDictionary *)data NS_UNAVAILABLE;
- (instancetype)initWithRecordID:(SKYRecordID *)recordId data:(NSDictionary *)data NS_UNAVAILABLE;

+ (instancetype)userWithUserRecordID:(SKYUserRecordID *)recordID;
+ (instancetype)userWithUserRecordID:(SKYUserRecordID *)recordID data:(NSDictionary *)data;

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
