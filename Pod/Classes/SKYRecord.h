//
//  SKYRecord.h
//  askq
//
//  Created by Kenji Pa on 16/1/15.
//  Copyright (c) 2015 Rocky Chan. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SKYAccessControl.h"
#import "SKYRecordID.h"
#import "SKYUserRecordID.h"

extern NSString *const SKYRecordTypeUserRecord;

@interface SKYRecord : NSObject <NSCopying>

+ (instancetype)recordWithRecordType:(NSString *)recordType;
+ (instancetype)recordWithRecordType:(NSString *)recordType name:(NSString *)recordName;
+ (instancetype)recordWithRecordType:(NSString *)recordType
                                name:(NSString *)recordName
                                data:(NSDictionary *)data;
+ (instancetype)recordWithRecordID:(SKYRecordID *)recordId data:(NSDictionary *)data;

/**
 Instantiates an instance of <SKYRecord> with the specified record type with a randomly generated
 <SKYRecordID>.

 @param recordType Record type of the record.
 @return An instance of SKYRecord.
 */
- (instancetype)initWithRecordType:(NSString *)recordType;
- (instancetype)initWithRecordType:(NSString *)recordType name:(NSString *)recordName;
- (instancetype)initWithRecordType:(NSString *)recordType
                          recordID:(SKYRecordID *)recordId __deprecated;
- (instancetype)initWithRecordType:(NSString *)recordType
                          recordID:(SKYRecordID *)recordId
                              data:(NSDictionary *)data __deprecated;
- (instancetype)initWithRecordType:(NSString *)recordType
                              name:(NSString *)recordName
                              data:(NSDictionary *)data;
- (instancetype)initWithRecordID:(SKYRecordID *)recordId
                            data:(NSDictionary *)data NS_DESIGNATED_INITIALIZER;

- (id)objectForKey:(id)key;
- (id)objectForKeyedSubscript:(id)key;

- (void)setObject:(id)object forKey:(id<NSCopying>)key;
- (void)setObject:(id)object forKeyedSubscript:(id<NSCopying>)key;

- (SKYRecord *)referencedRecordForKey:(id)key;

@property (nonatomic, readonly, copy) SKYRecordID *recordID;
@property (nonatomic, readonly, copy) NSString *recordType;
@property (nonatomic, readonly, copy) SKYUserRecordID *ownerUserRecordID;
@property (nonatomic, readonly, copy) NSDate *creationDate;
@property (nonatomic, readonly, copy) SKYUserRecordID *creatorUserRecordID;
@property (nonatomic, readonly, copy) NSDate *modificationDate;
@property (nonatomic, readonly, copy) SKYUserRecordID *lastModifiedUserRecordID;
@property (nonatomic, readonly, copy) NSString *recordChangeTag;
@property (strong, nonatomic, readonly) SKYAccessControl *accessControl;
@property (nonatomic, readonly, copy) NSDictionary *dictionary;

/**
 Returns an NSDictionary of transient fields.

 Transient fields are attached to an instance of SKYRecord and it is never persisted on server,
 but they maybe returned as extra data about the record when fetched or queried from server.
 */
@property (nonatomic, readonly, copy) NSMutableDictionary *transient;

@end
