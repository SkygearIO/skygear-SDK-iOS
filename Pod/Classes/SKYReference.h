//
//  SKYReference.h
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

#import "SKYRecord.h"
#import "SKYRecordID.h"

NS_ASSUME_NONNULL_BEGIN

__attribute__((deprecated)) typedef enum SKYReferenceAction : NSInteger {
    SKYReferenceActionNone = 0,
    SKYReferenceActionDeleteSelf = 1,
} SKYReferenceAction;

/**
 * SKYReference represents the value of referencing another record.
 *
 * While it is not possible to put a record in another record, it is possible
 * to put a reference to a record in another record. Doing so allows
 * the two references to be modified independently from each other. When
 * querying data from database, it is possible to include data of a referenced
 * record together in a single request.
 */
@interface SKYReference : NSObject <NSCopying, NSCoding>

- (instancetype)init NS_UNAVAILABLE;

/**
 * Creates an instance of reference with the specified record.
 *
 * @note The specified record should be saved before this record is saved.
 *
 * @param record the record to set reference to
 * @return a record reference
 */
- (instancetype)initWithRecord:(SKYRecord *)record;

/**
 * This method is deprecated.
 */
- (instancetype)initWithRecord:(SKYRecord *)record
                        action:(SKYReferenceAction)action __attribute__((deprecated));

/**
 * Creates an instance of reference with record type and record ID.
 *
 * @param recordType record type
 * @param recordID record ID
 * @return a record reference
 */
- (instancetype)initWithRecordType:(NSString *)recordType
                          recordID:(NSString *)recordID NS_DESIGNATED_INITIALIZER;

/**
 * This method is deprecated.
 */
- (instancetype)initWithRecordID:(SKYRecordID *)recordID __attribute__((deprecated));

/**
 * This method is deprecated.
 */
- (instancetype)initWithRecordID:(SKYRecordID *)recordID
                          action:(SKYReferenceAction)action __attribute__((deprecated));

/**
 * Creates an instance of reference with the specified record.
 *
 * @note The specified record should be saved before this record is saved.
 *
 * @param record the record to set reference to
 * @return a record reference
 */
+ (instancetype)referenceWithRecord:(SKYRecord *)record;

/**
 * This method is deprecated.
 */
+ (instancetype)referenceWithRecord:(SKYRecord *)record
                             action:(SKYReferenceAction)action __attribute__((deprecated));

/**
 * Creates an instance of reference with record type and record ID.
 *
 * @param recordType record type
 * @param recordID record ID
 * @return a record reference
 */
+ (instancetype)referenceWithRecordType:(NSString *)recordType recordID:(NSString *)recordID;

/**
 * This method is deprecated.
 */
+ (instancetype)referenceWithRecordID:(SKYRecordID *)recordID __attribute__((deprecated));

/**
 * This method is deprecated.
 */
+ (instancetype)referenceWithRecordID:(SKYRecordID *)recordID
                               action:(SKYReferenceAction)action __attribute__((deprecated));

/**
 * Compares if two references are equal.
 */
- (BOOL)isEqualToReference:(SKYReference *_Nullable)reference;

/**
 * This property is deprecated.
 */
@property (nonatomic, readonly, assign) SKYReferenceAction referenceAction
    __attribute__((deprecated));

/**
 * Gets the record type of the reference.
 */
@property (nonatomic, readonly, copy) NSString *recordType;

/**
 * Gets the record ID of the reference.
 */
@property (nonatomic, readonly, copy) NSString *recordID;

/**
 * Returns the record used to create this reference.
 *
 * If the reference is fetched from the database, this property
 * will return null.
 */
@property (strong, nonatomic, readonly) SKYRecord *_Nullable record;

@end

NS_ASSUME_NONNULL_END
