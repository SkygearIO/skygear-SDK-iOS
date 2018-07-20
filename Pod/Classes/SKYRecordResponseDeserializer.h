//
//  SKYRecordResponseDeserializer.h
//  SKYKit
//
//  Copyright 2018 Oursky Ltd.
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

@class SKYRecord;

NS_ASSUME_NONNULL_BEGIN

/**
 The record response deserializer is responsible for deserialize record response from server.

 Record response usually consist of an array of record dictionary or a error dictionary, depends
 on whether individual record operation was a success or not. This deserializer abstract the logic
 for deserializing such data.

 This class is not intended for general use.
 */
@interface SKYRecordResponseDeserializer : NSObject

/**
 Deserialize response dictionary into SKYRecord and NSError.

 @param dictionary result dictionary of either record or error
 @param block the handler to be called with a deserialized record or error.
 */
- (void)deserializeResponseDictionary:(NSDictionary *)dictionary
                                block:(void (^_Nonnull)(NSString *_Nullable recordType,
                                                        NSString *_Nullable recordID,
                                                        SKYRecord *_Nullable record,
                                                        NSError *_Nullable error))block;

/**
 Deserialize an array of response dictionary into SKYRecord and NSError.

 @param array array containing result dictionary of either record or error
 @param block the handler to be called with a deserialized record or error.
 */
- (void)deserializeResponseArray:(NSArray<NSDictionary *> *)array
                           block:(void (^_Nonnull)(NSString *_Nullable recordType,
                                                   NSString *_Nullable recordID,
                                                   SKYRecord *_Nullable record,
                                                   NSError *_Nullable error))block;

@end

NS_ASSUME_NONNULL_END
