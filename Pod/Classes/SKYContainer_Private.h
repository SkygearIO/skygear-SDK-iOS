//
//  SKYContainer_Private.h
//  askq
//
//  Created by Patrick Cheung on 8/2/15.
//  Copyright (c) 2015 Rocky Chan. All rights reserved.
//

#import "SKYContainer.h"

@interface SKYContainer()

/**
 Loads <SKYUserRecordID> and <SKYAccessToken> from persistent storage. Use this method to resume user's access credentials
 after application launch.
 
 This method is called when <SKYContainer> is `-init` is called. You should not call this method manually.
 */
- (void)loadAccessCurrentUserRecordIDAndAccessToken;

@property (nonatomic, strong) SKYPubsub *internalPubsubClient;

@property (nonatomic, copy, setter=setAuthenticationErrorHandler:) void (^authErrorHandler)(SKYContainer *container, SKYAccessToken *token, NSError *error);

@end
