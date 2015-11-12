//
//  SKYUserLogoutOperation.h
//  askq
//
//  Created by Patrick Cheung on 8/2/15.
//  Copyright (c) 2015 Rocky Chan. All rights reserved.
//

#import "SKYOperation.h"

/**
 <SKYUserLogoutOperation> is a subclass of <SKYDatabaseOperation> that implements ends a user login
 session in
 container. Use this to log out the currently logged in user of an <SKYContainer>.
 */
@interface SKYUserLogoutOperation : SKYOperation

/**
 Sets or returns block to be called when the logout operation completes. If an error occurred, the
 error
 will be specified.
 */
@property (nonatomic, copy) void (^logoutCompletionBlock)(NSError *error);

@end
