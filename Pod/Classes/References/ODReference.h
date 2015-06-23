//
//  ODReference.h
//  askq
//
//  Created by Kenji Pa on 20/1/15.
//  Copyright (c) 2015 Rocky Chan. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ODRecord.h"
#import "ODRecordID.h"

typedef enum ODReferenceAction : NSInteger {
    ODReferenceActionNone       = 0,
    ODReferenceActionDeleteSelf = 1,
} ODReferenceAction;

@interface ODReference : NSObject<NSCoding>

- (instancetype)initWithRecord:(ODRecord *)record;
- (instancetype)initWithRecord:(ODRecord *)record action:(ODReferenceAction)action;
- (instancetype)initWithRecordID:(ODRecordID *)recordID;
- (instancetype)initWithRecordID:(ODRecordID *)recordID action:(ODReferenceAction)action;

- (BOOL)isEqualToReference:(ODReference *)reference;

@property (nonatomic, readonly, assign) ODReferenceAction referenceAction;
@property (nonatomic, readonly, copy) ODRecordID *recordID;

@property (strong, nonatomic, readonly) ODRecord *record;

@end
