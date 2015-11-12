//
//  SKYQueryNotification.h
//  askq
//
//  Created by Kenji Pa on 30/1/15.
//  Copyright (c) 2015 Rocky Chan. All rights reserved.
//

#import "SKYNotification.h"

#import "SKYRecordID.h"

@interface SKYQueryNotification : SKYNotification

// is it really useful?
@property (nonatomic, readonly, assign) BOOL isPublicDatabase;

@property (nonatomic, readonly, copy) SKYRecordID *recordID;

@end
