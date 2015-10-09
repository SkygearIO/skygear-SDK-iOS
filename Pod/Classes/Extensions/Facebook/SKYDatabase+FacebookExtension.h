//
//  SKYDatabase+FacebookExtension.h
//  askq
//
//  Created by Kenji Pa on 23/1/15.
//  Copyright (c) 2015 Rocky Chan. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SKYDatabase.h"
#import "SKYUserRecordID.h"

@interface SKYDatabase(FacebookExtension)

- (void)findUserByFacebookFriendsOfUser:(SKYUserRecordID *)userRecordID
                      completionHandler:(void (^)(NSArray *users, NSError *error))completionHandler;

@end
