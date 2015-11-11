//
//  SKYFacebookOperation.h
//  askq
//
//  Created by Kenji Pa on 23/1/15.
//  Copyright (c) 2015 Rocky Chan. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SKYDatabaseOperation.h"
#import "SKYUserRecordID.h"

@interface SKYFacebookOperation : SKYDatabaseOperation

@property (nonatomic, copy) SKYUserRecordID *userRecordID;

@end
