//
//  SKYRecord.h
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

#import "SKYAccessControl.h"
#import "SKYRecordID.h"

NS_ASSUME_NONNULL_BEGIN

/// Undocumented
extern NSString *const SKYRecordTypeUserRecord;

/// Undocumented
@interface SKYRecord : NSObject <NSCopying, NSCoding>

/// Undocumented
+ (instancetype)recordWithRecordType:(NSString *)recordType;
/// Undocumented
+ (instancetype)recordWithRecordType:(NSString *)recordType name:(NSString *)recordName;
/// Undocumented
+ (instancetype)recordWithRecordType:(NSString *)recordType
                                name:(NSString *)recordName
                                data:(NSDictionary *_Nullable)data;
/// Undocumented
+ (instancetype)recordWithRecordID:(SKYRecordID *)recordId data:(NSDictionary *_Nullable)data;

/**
 Instantiates an instance of <SKYRecord> with the specified record type with a randomly generated
 <SKYRecordID>.

 @param recordType Record type of the record.
 @return An instance of SKYRecord.
 */
- (instancetype)init NS_UNAVAILABLE;
/// Undocumented
- (instancetype)initWithRecordType:(NSString *)recordType;
/// Undocumented
- (instancetype)initWithRecordType:(NSString *)recordType name:(NSString *)recordName;
/// Undocumented
- (instancetype)initWithRecordType:(NSString *)recordType
                          recordID:(SKYRecordID *)recordId __deprecated;
/// Undocumented
- (instancetype)initWithRecordType:(NSString *)recordType
                          recordID:(SKYRecordID *)recordId
                              data:(NSDictionary *_Nullable)data __deprecated;
/// Undocumented
- (instancetype)initWithRecordType:(NSString *)recordType
                              name:(NSString *)recordName
                              data:(NSDictionary *_Nullable)data;
/// Undocumented
- (instancetype)initWithRecordID:(SKYRecordID *)recordId
                            data:(NSDictionary *_Nullable)data NS_DESIGNATED_INITIALIZER;

/// Undocumented
- (id _Nullable)objectForKey:(id)key;
/// Undocumented
- (id _Nullable)objectForKeyedSubscript:(id)key;

/// Undocumented
- (void)setObject:(id)object forKey:(id<NSCopying> _Nullable)key;
/// Undocumented
- (void)setObject:(id)object forKeyedSubscript:(id<NSCopying> _Nullable)key;

/// Undocumented
- (SKYRecord *_Nullable)referencedRecordForKey:(id)key;

/// Undocumented
@property (nonatomic, readonly, copy) SKYRecordID *recordID;
/// Undocumented
@property (nonatomic, readonly, copy) NSString *recordType;
/// Undocumented
@property (nonatomic, readonly, copy) NSString *_Nullable ownerUserRecordID;
/// Undocumented
@property (nonatomic, readonly, copy) NSDate *_Nullable creationDate;
/// Undocumented
@property (nonatomic, readonly, copy) NSString *_Nullable creatorUserRecordID;
/// Undocumented
@property (nonatomic, readonly, copy) NSDate *_Nullable modificationDate;
/// Undocumented
@property (nonatomic, readonly, copy) NSString *_Nullable lastModifiedUserRecordID;
/// Undocumented
@property (nonatomic, readonly, copy) NSString *_Nullable recordChangeTag;
/**
 Gets or sets the access control settings for this record.
 */
@property (nonatomic, readwrite, strong) SKYAccessControl *_Nullable accessControl;
/// Undocumented
@property (nonatomic, readonly, copy) NSDictionary *dictionary;

/**
 Returns an NSDictionary of transient fields.

 Transient fields are attached to an instance of SKYRecord and it is never persisted on server,
 but they maybe returned as extra data about the record when fetched or queried from server.
 */
@property (nonatomic, readonly, copy) NSMutableDictionary *transient;

@end

NS_ASSUME_NONNULL_END
