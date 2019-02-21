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

extern NSString *SKYRecordConcatenatedID(NSString *recordType, NSString *recordID);
extern NSString *SKYRecordTypeFromConcatenatedID(NSString *concatenatedID);
extern NSString *SKYRecordIDFromConcatenatedID(NSString *concatenatedID);

/// Undocumented
extern NSString *const SKYRecordTypeUserRecord;

/**
 * SKYRecord represents a collection of key-value data that can be fetched,
 * saved, queried and deleted from the database.
 *
 * Record must have a record type, which is used by the database to group
 * different kinds of records. Each kind of record has its own set of fields
 * with matching data type. For example, a `book` record type will have a
 * `title` field and a `year` field, while an `author` record type will have a
 * `name` and `picture` field.
 *
 * Record is identified with a record ID, which must be unique among all
 * records sharing the same type. If you creates an instance with the same
 * record ID, the existing record with the same record ID will be overwritten
 * when saving.
 *
 * You may use the convenient methods provided by SKYDatabase to operates on
 * a record.
 */
@interface SKYRecord : NSObject <NSCopying, NSCoding>

/**
 * This method is deprecated.
 */
+ (instancetype)recordWithRecordType:(NSString *)recordType __attribute__((deprecated));

/**
 * Creates an instance of record with the specified type.
 *
 * @param recordType the record type
 * @return an instance of SKYRecord
 */
+ (instancetype)recordWithType:(NSString *)recordType;

/**
 * This method is deprecated.
 */
+ (instancetype)recordWithRecordType:(NSString *)recordType
                                name:(NSString *_Nullable)recordName __attribute__((deprecated));

/**
 * Creates an instance of record with the specified type and record ID.
 *
 * @param recordType the record type
 * @param recordID the record ID
 * @return an instance of SKYRecord
 */
+ (instancetype)recordWithType:(NSString *)recordType recordID:(NSString *_Nullable)recordID;

/**
 * This method is deprecated.
 */
+ (instancetype)recordWithRecordType:(NSString *)recordType
                                name:(NSString *_Nullable)recordName
                                data:(NSDictionary<NSString *, id> *_Nullable)data
    __attribute__((deprecated));

/**
 * Creates an instance of record with the specified type and record ID and
 * optional key-value data.
 *
 * @param recordType the record type
 * @param recordID the record ID
 * @param data the record data
 * @return an instance of SKYRecord
 */
+ (instancetype)recordWithType:(NSString *)recordType
                      recordID:(NSString *_Nullable)recordID
                          data:(NSDictionary<NSString *, id> *_Nullable)data;

/**
 * This method is deprecated.
 */
+ (instancetype)recordWithRecordID:(SKYRecordID *)recordId
                              data:(NSDictionary<NSString *, id> *_Nullable)data
    __attribute__((deprecated));

/**
 * This method is deprecated.
 */
- (instancetype)initWithRecordType:(NSString *)recordType __attribute__((deprecated));

- (instancetype)init NS_UNAVAILABLE;

/**
 * Creates an instance of record with the specified type.
 *
 * @param recordType the record type
 * @return an instance of SKYRecord
 */
- (instancetype)initWithType:(NSString *)recordType;

/**
 * This method is deprecated.
 */
- (instancetype)initWithRecordType:(NSString *)recordType
                              name:(NSString *_Nullable)recordName __attribute__((deprecated));

/**
 * Creates an instance of record with the specified type and record ID.
 *
 * @param recordType the record type
 * @param recordID the record ID
 * @return an instance of SKYRecord
 */
- (instancetype)initWithType:(NSString *)recordType recordID:(NSString *_Nullable)recordID;

/**
 * This method is deprecated.
 */
- (instancetype)initWithRecordType:(NSString *)recordType
                              name:(NSString *_Nullable)recordName
                              data:(NSDictionary<NSString *, id> *_Nullable)data
    __attribute__((deprecated));

/**
 * Creates an instance of record with the specified type and record ID and
 * optional key-value data.
 *
 * @param recordType the record type
 * @param recordID the record ID
 * @param data the record data
 * @return an instance of SKYRecord
 */
- (instancetype)initWithType:(NSString *)recordType
                    recordID:(NSString *_Nullable)recordID
                        data:(NSDictionary<NSString *, id> *_Nullable)data
    NS_DESIGNATED_INITIALIZER;

/**
 * This method is deprecated.
 */
- (instancetype)initWithRecordID:(SKYRecordID *)recordID
                            data:(NSDictionary<NSString *, id> *_Nullable)data
    __attribute__((deprecated));

/// Undocumented
- (id _Nullable)objectForKey:(id)key;
/// Undocumented
- (id _Nullable)objectForKeyedSubscript:(id)key;

/// Undocumented
- (void)setObject:(id _Nullable)object forKey:(id<NSCopying> _Nullable)key;
/// Undocumented
- (void)setObject:(id _Nullable)object forKeyedSubscript:(id<NSCopying> _Nullable)key;

/// Undocumented
- (SKYRecord *_Nullable)referencedRecordForKey:(NSString *)key;

/**
 Returns the record type of the record.

 Record type is used to identify different types of records. Records with the same record type
 should share the same set of fields with matching data type. If your application need a new record
 that has different set of fields, you should use a different record type.
 */
@property (nonatomic, readonly, copy) NSString *recordType;
/**
 Returns the record ID of the record.

 The record ID can be used by application to identify a record by using a string. The value of the
 ID should be unique among all records with the same record type. Saving a record with the same
 record ID will result in the same record in the database being overwritten.
 */
@property (nonatomic, readonly, copy) NSString *recordID;

/**
 Returns deprecated SKYRecordID of this record.

 This property aims to provide a quickfix for older applications which use SKYRecordID
 to represent record identifier. This property has the same value as the `recordID`
 property in previous versions.
 */
@property (nonatomic, readonly, copy) SKYRecordID *deprecatedID __attribute((deprecated));

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
@property (nonatomic, readonly, copy) NSDictionary<NSString *, id> *dictionary;

/**
 Returns an NSDictionary of transient fields.

 Transient fields are attached to an instance of SKYRecord and it is never persisted on server,
 but they maybe returned as extra data about the record when fetched or queried from server.
 */
@property (nonatomic, readonly, copy) NSMutableDictionary<NSString *, id> *transient;

/**
 Returns whether the record is deleted.
 */
@property (nonatomic, readonly) BOOL deleted;

@end

NS_ASSUME_NONNULL_END
