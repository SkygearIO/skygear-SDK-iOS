//
//  SKYFollowReference_Private.h
//  askq
//
//  Created by Kenji Pa on 2/2/15.
//  Copyright (c) 2015 Rocky Chan. All rights reserved.
//

#import "SKYFollowReference.h"

#import "SKYUserRecordID.h"

@interface SKYFollowReference ()

- (instancetype)initWithUserRecordID:(SKYUserRecordID *)userRecordID;
- (instancetype)initWithUserRecordID:(SKYUserRecordID *)recordID followType:(NSString *)followType;

@end
