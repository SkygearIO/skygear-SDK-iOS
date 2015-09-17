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
@property (nonatomic, readwrite, copy) ODUserRecordID *ownerUserRecordID;
@property (nonatomic, readwrite, copy) NSDate *creationDate;
@property (nonatomic, readwrite, copy) ODUserRecordID *creatorUserRecordID;
@property (nonatomic, readwrite, copy) NSDate *modificationDate;
@property (nonatomic, readwrite, copy) ODUserRecordID *lastModifiedUserRecordID;
@property (strong, nonatomic, readwrite) ODAccessControl *accessControl;

@end
