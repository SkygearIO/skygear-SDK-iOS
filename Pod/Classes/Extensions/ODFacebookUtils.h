//
//  ODFacebookUtils.h
//  askq
//
//  Created by Kenji Pa on 23/1/15.
//  Copyright (c) 2015 Rocky Chan. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ODUserRecordID.h"

@interface ODFacebookUtils : NSObject

+ (void)findFacebookFriendsOfUser:(ODUserRecordID *)userRecordID;

@end
