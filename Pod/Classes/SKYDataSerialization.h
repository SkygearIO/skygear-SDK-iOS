//
//  SKYDataSerialization.h
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

#import "SKYAsset.h"

NS_ASSUME_NONNULL_BEGIN

/// Undocumented
extern NSString *const SKYDataSerializationCustomTypeKey;
/// Undocumented
extern NSString *const SKYDataSerializationReferenceType;
/// Undocumented
extern NSString *const SKYDataSerializationDateType;
/// Undocumented
extern NSString *const SKYDataSerializationRelationType;
/// Undocumented
extern NSString *const SKYDataSerializationSequenceType;

/// Undocumented
NSString *remoteFunctionName(NSString *localFunctionName);
/// Undocumented
NSString *localFunctionName(NSString *remoteFunctionName);

/// Undocumented
@interface SKYDataSerialization : NSObject

/// Undocumented
+ (NSDate *_Nullable)dateFromString:(NSString *)dateStr;
/// Undocumented
+ (NSString *_Nullable)stringFromDate:(NSDate *)date;
/// Undocumented
+ (id _Nullable)deserializeObjectWithValue:(id)value;
/// Undocumented
+ (SKYAsset *_Nullable)deserializeAssetWithDictionary:(NSDictionary *)data;

/// Undocumented
+ (id)serializeObject:(id _Nullable)obj;

@end

NS_ASSUME_NONNULL_END
