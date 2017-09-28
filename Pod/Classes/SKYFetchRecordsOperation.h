//
//  SKYFetchRecordsOperation.h
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

#import "SKYDatabaseOperation.h"

NS_ASSUME_NONNULL_BEGIN

/**
 <SKYFetchRecordsOperation> is a subclass of <SKYOperation> that implements fetching records from
 Skygear. Use this to
 fetch a number of records by specifying an array of <SKYRecordID>s.

 When the operation completes, the <fetchRecordsCompletionBlock> will be called
 with all the fetched records, or an error will be returned stating the error. For each
 <SKYRecordID>, the <perRecordCompletionBlock>
 will be called with the fetched record or an error if one occurred.
 */
@interface SKYFetchRecordsOperation : SKYDatabaseOperation

/**
 Instantiates an instance of <SKYFetchRecordsOperation> with the desired <SKYRecordID>s.

 @param recordIDs An array of <SKYRecordID>s of records to be fetched from Skygear.
 @return an instance of SKYFetchRecordsOperation.
 */
- (instancetype)initWithRecordIDs:(NSArray<SKYRecordID *> *)recordIDs;

/**
 Creates and returns an instance of <SKYFetchRecordsOperation> with the desired <SKYRecordID>s.

 @param recordIDs An array of <SKYRecordID>s of records to be fetched from Skygear.
 @return an instance of SKYFetchRecordsOperation.
 */
+ (instancetype)operationWithRecordIDs:(NSArray<SKYRecordID *> *)recordIDs;

/**
 Sets or returns an array of <SKYRecordID>s to be fetched from Skygear.
 */
@property (nonatomic, copy) NSArray<SKYRecordID *> *recordIDs;

/**
 Sets or returns an array of desired keys to be fetched from each record. A subset of keys for each
 record
 will be fetched from Skygear. <SKYRecord> without the specified keys will not have such key set.
 */
@property (nonatomic, copy) NSArray<NSString *> *desiredKeys;

/**
 Sets or returns a block to be called for progress information for each <SKYRecordID>. This is only
 called
 when progress information is available.
 */
@property (nonatomic, copy) void (^_Nullable perRecordProgressBlock)
    (SKYRecordID *_Nullable recordID, double progress);

/**
 Sets or returns a block to be called when a record fetch operation completes for a <SKYRecordID>.
 If
 the fetch results in an error, the error will be specified.

 This block is not called when the entire operation results in an error.
 */
@property (nonatomic, copy) void (^_Nullable perRecordCompletionBlock)
    (SKYRecord *_Nullable record, SKYRecordID *_Nullable recordID, NSError *_Nullable error);

/**
 Sets or returns a block to be called when the entire operation completes. The fetched records are
 specified
 in an <NSDictionary>. If an error occurred for the entire operation (not individual record), an
 error will
 be specified.
 */
@property (nonatomic, copy) void (^_Nullable fetchRecordsCompletionBlock)
    (NSDictionary *_Nullable recordsByRecordID, NSError *_Nullable operationError);

@end

NS_ASSUME_NONNULL_END
