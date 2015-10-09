//
//  SKYFacebookFindUserByFriendOperation.h
//  askq
//
//  Created by Kenji Pa on 23/1/15.
//  Copyright (c) 2015 Rocky Chan. All rights reserved.
//

#import "SKYFacebookOperation.h"

#import "SKYUserRecordID.h"

@interface SKYFacebookFindUserByFriendOperation : SKYFacebookOperation

- (instancetype)initWithUserRecordID:(SKYUserRecordID *)recordID;

@end
