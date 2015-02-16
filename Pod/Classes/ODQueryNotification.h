//
//  ODQueryNotification.h
//  askq
//
//  Created by Kenji Pa on 30/1/15.
//  Copyright (c) 2015 Rocky Chan. All rights reserved.
//

#import "ODNotification.h"

#import "ODRecordID.h"

@interface ODQueryNotification : ODNotification

// is it really useful?
@property (nonatomic, readonly, assign) BOOL isPublicDatabase;

@property(nonatomic, readonly, copy) ODRecordID *recordID;

@end
