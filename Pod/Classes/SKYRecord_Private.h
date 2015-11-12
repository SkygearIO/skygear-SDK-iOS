//
//  SKYRecord_Private.h
//  askq
//
//  Created by Kenji Pa on 2/2/15.
//  Copyright (c) 2015 Rocky Chan. All rights reserved.
//

#import "SKYRecord.h"

@interface SKYRecord ()

@property (nonatomic, readwrite, copy) SKYRecordID *recordID;
@property (nonatomic, readwrite, copy) SKYUserRecordID *ownerUserRecordID;
@property (nonatomic, readwrite, copy) NSDate *creationDate;
@property (nonatomic, readwrite, copy) SKYUserRecordID *creatorUserRecordID;
@property (nonatomic, readwrite, copy) NSDate *modificationDate;
@property (nonatomic, readwrite, copy) SKYUserRecordID *lastModifiedUserRecordID;
@property (strong, nonatomic, readwrite) SKYAccessControl *accessControl;

@end
