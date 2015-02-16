//
//  ODDatabase+FacebookExtension.h
//  askq
//
//  Created by Kenji Pa on 23/1/15.
//  Copyright (c) 2015 Rocky Chan. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ODDatabase.h"
#import "ODUserRecordID.h"

@interface ODDatabase(FacebookExtension)

- (void)findUserByFacebookFriendsOfUser:(ODUserRecordID *)userRecordID
                      completionHandler:(void (^)(NSArray *users, NSError *error))completionHandler;

@end
