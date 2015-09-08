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

@property (nonatomic, strong) ODPubsub *internalPubsubClient;

@property (nonatomic, copy, setter=setAuthenticationErrorHandler:) void (^authErrorHandler)(ODContainer *container, ODAccessToken *token, NSError *error);

@end
