//
//  ODFacebookFindUserByFriendOperation.h
//  askq
//
//  Created by Kenji Pa on 23/1/15.
//  Copyright (c) 2015 Rocky Chan. All rights reserved.
//

#import "ODFacebookOperation.h"

#import "ODUserRecordID.h"

@interface ODFacebookFindUserByFriendOperation : ODFacebookOperation

- (instancetype)initWithUserRecordID:(ODUserRecordID *)recordID;

@end
