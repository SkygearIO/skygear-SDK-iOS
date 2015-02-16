//
//  ODRecord_Private.h
//  askq
//
//  Created by Kenji Pa on 2/2/15.
//  Copyright (c) 2015 Rocky Chan. All rights reserved.
//

#import "ODRecord.h"

@interface ODRecord()

@property (nonatomic, readwrite, copy) ODRecordID *recordID;
@property (nonatomic, readwrite, copy) NSDate *creationDate;

@end
