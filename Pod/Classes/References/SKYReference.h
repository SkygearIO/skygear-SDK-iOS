//
//  SKYReference.h
//  askq
//
//  Created by Kenji Pa on 20/1/15.
//  Copyright (c) 2015 Rocky Chan. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SKYRecord.h"
#import "SKYRecordID.h"

typedef enum SKYReferenceAction : NSInteger {
    SKYReferenceActionNone       = 0,
    SKYReferenceActionDeleteSelf = 1,
} SKYReferenceAction;

@interface SKYReference : NSObject<NSCoding>

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
