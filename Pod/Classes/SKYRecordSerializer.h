//
//  SKYRecordSerializer.h
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

#import "SKYRecord.h"
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// Undocumented
@interface SKYRecordSerializer : NSObject

/**
 Sets or return whether the serializer will serialize transient dictionary.

 Default is NO.
 */
@property (nonatomic, readwrite) BOOL serializeTransientDictionary;

/// Undocumented
+ (instancetype _Nullable)serializer;

/// Undocumented
- (NSDictionary<NSString *, id> *)dictionaryWithRecord:(SKYRecord *)record;
/// Undocumented
- (NSData *_Nullable)JSONDataWithRecord:(SKYRecord *)record error:(NSError **_Nullable)error;

@end

NS_ASSUME_NONNULL_END
