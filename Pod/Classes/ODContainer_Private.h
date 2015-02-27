//
//  ODContainer_Private.h
//  askq
//
//  Created by Patrick Cheung on 8/2/15.
//  Copyright (c) 2015 Rocky Chan. All rights reserved.
//

#import "ODContainer.h"

@interface ODContainer()

/**
 Loads <ODUserRecordID> and <ODAccessToken> from persistent storage. Use this method to resume user's access credentials
 after application launch.
 
 This method is called when <ODContainer> is `-init` is called. You should not call this method manually.
 */
- (void)loadAccessCurrentUserRecordIDAndAccessToken;

/**
 Updates the <currentUserRecordID> and <currentAccessToken>. The updated access credentials are also stored in persistent
 storage.
 
 This method is called when operation sign up, log in and log out is performed using the container's convenient
 method and when the operation is completed successfully. You should not call this method manually.
 
 @see -loadAccessCurrentUserRecordIDAndAccessToken
 */
- (void)updateWithUserRecordID:(ODUserRecordID *)userRecord accessToken:(ODAccessToken *)accessToken;

@end
