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

typedef enum SKYReferenceAction : NSInteger {
    SKYReferenceActionNone = 0,
    SKYReferenceActionDeleteSelf = 1,
} SKYReferenceAction;

@interface SKYReference : NSObject <NSCoding>

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithRecord:(SKYRecord *)record;
- (instancetype)initWithRecord:(SKYRecord *)record action:(SKYReferenceAction)action;
- (instancetype)initWithRecordID:(SKYRecordID *)recordID;
- (instancetype)initWithRecordID:(SKYRecordID *)recordID action:(SKYReferenceAction)action;

+ (instancetype)referenceWithRecord:(SKYRecord *)record;
+ (instancetype)referenceWithRecord:(SKYRecord *)record action:(SKYReferenceAction)action;
+ (instancetype)referenceWithRecordID:(SKYRecordID *)recordID;
+ (instancetype)referenceWithRecordID:(SKYRecordID *)recordID action:(SKYReferenceAction)action;

- (BOOL)isEqualToReference:(SKYReference *)reference;

@property (nonatomic, readonly, assign) SKYReferenceAction referenceAction;
@property (nonatomic, readonly, copy) SKYRecordID *recordID;

@property (strong, nonatomic, readonly) SKYRecord *record;

@end
