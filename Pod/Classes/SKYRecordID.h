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

@interface SKYRecordID : NSObject <NSCopying, NSSecureCoding>

/**
 Instantiates an instance of SKYRecordID with a random record name.
 */
- (instancetype)init __deprecated;
- (instancetype)initWithRecordName:(NSString *)recordName __deprecated;

- (instancetype)initWithRecordType:(NSString *)type;
- (instancetype)initWithCanonicalString:(NSString *)canonicalString;
- (instancetype)initWithRecordType:(NSString *)type
                              name:(NSString *)recordName NS_DESIGNATED_INITIALIZER;

+ (instancetype)recordIDWithRecordType:(NSString *)type;
+ (instancetype)recordIDWithCanonicalString:(NSString *)canonicalString;
+ (instancetype)recordIDWithRecordType:(NSString *)type name:(NSString *)recordName;

- (BOOL)isEqualToRecordID:(SKYRecordID *)recordID;

@property (nonatomic, readonly, strong) NSString *recordType;
@property (nonatomic, readonly, strong) NSString *recordName;
@property (nonatomic, readonly, strong) NSString *canonicalString;

@end
