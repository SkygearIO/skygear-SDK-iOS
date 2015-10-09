//
//  SKYFacebookUtils.h
//  askq
//
//  Created by Kenji Pa on 23/1/15.
//  Copyright (c) 2015 Rocky Chan. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SKYUserRecordID.h"

@interface SKYFacebookUtils : NSObject

+ (void)findFacebookFriendsOfUser:(SKYUserRecordID *)userRecordID;

@end
