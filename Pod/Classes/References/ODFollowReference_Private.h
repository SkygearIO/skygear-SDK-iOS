//
//  ODFollowReference_Private.h
//  askq
//
//  Created by Kenji Pa on 2/2/15.
//  Copyright (c) 2015 Rocky Chan. All rights reserved.
//

#import "ODFollowReference.h"

#import "ODUserRecordID.h"

@interface ODFollowReference ()

- (instancetype)initWithUserRecordID:(ODUserRecordID *)userRecordID;
- (instancetype)initWithUserRecordID:(ODUserRecordID *)recordID followType:(NSString *)followType;

@end
