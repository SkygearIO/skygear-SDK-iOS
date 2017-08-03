//
//  SKYRecordID.h
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

NS_ASSUME_NONNULL_BEGIN

/// Undocumented
@interface SKYRecordID : NSObject <NSCopying, NSSecureCoding>

/**
 Instantiates an instance of SKYRecordID with a random record name.
 */
- (instancetype)init NS_UNAVAILABLE;

/// Undocumented
- (instancetype)initWithRecordType:(NSString *)type;
/// Undocumented
- (instancetype)initWithCanonicalString:(NSString *)canonicalString;
/// Undocumented
- (instancetype)initWithRecordType:(NSString *)type
                              name:(NSString *_Nullable)recordName NS_DESIGNATED_INITIALIZER;

/// Undocumented
+ (instancetype)recordIDWithRecordType:(NSString *)type;
/// Undocumented
+ (instancetype)recordIDWithCanonicalString:(NSString *)canonicalString;
/// Undocumented
+ (instancetype)recordIDWithRecordType:(NSString *)type name:(NSString *_Nullable)recordName;

/// Undocumented
- (BOOL)isEqualToRecordID:(SKYRecordID *_Nullable)recordID;

/// Undocumented
@property (nonatomic, readonly, strong) NSString *recordType;
/// Undocumented
@property (nonatomic, readonly, strong) NSString *recordName;
/// Undocumented
@property (nonatomic, readonly, strong) NSString *canonicalString;

@end

NS_ASSUME_NONNULL_END
