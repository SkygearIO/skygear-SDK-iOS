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

/// Undocumented
typedef enum SKYReferenceAction : NSInteger {
    SKYReferenceActionNone = 0,
    SKYReferenceActionDeleteSelf = 1,
} SKYReferenceAction;

/// Undocumented
@interface SKYReference : NSObject <NSCoding>

/// Undocumented
- (instancetype)init NS_UNAVAILABLE;
/// Undocumented
- (instancetype)initWithRecord:(SKYRecord *)record;
/// Undocumented
- (instancetype)initWithRecord:(SKYRecord *)record action:(SKYReferenceAction)action;
/// Undocumented
- (instancetype)initWithRecordID:(SKYRecordID *)recordID;
/// Undocumented
- (instancetype)initWithRecordID:(SKYRecordID *)recordID action:(SKYReferenceAction)action;

/// Undocumented
+ (instancetype)referenceWithRecord:(SKYRecord *)record;
/// Undocumented
+ (instancetype)referenceWithRecord:(SKYRecord *)record action:(SKYReferenceAction)action;
/// Undocumented
+ (instancetype)referenceWithRecordID:(SKYRecordID *)recordID;
/// Undocumented
+ (instancetype)referenceWithRecordID:(SKYRecordID *)recordID action:(SKYReferenceAction)action;

/// Undocumented
- (BOOL)isEqualToReference:(SKYReference *_Nullable)reference;

/// Undocumented
@property (nonatomic, readonly, assign) SKYReferenceAction referenceAction;
/// Undocumented
@property (nonatomic, readonly, copy) SKYRecordID *recordID;

/// Undocumented
@property (strong, nonatomic, readonly) SKYRecord *_Nullable record;

@end

NS_ASSUME_NONNULL_END
