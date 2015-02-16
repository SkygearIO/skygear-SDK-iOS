//
//  ODUserLogoutOperation.h
//  askq
//
//  Created by Patrick Cheung on 8/2/15.
//  Copyright (c) 2015 Rocky Chan. All rights reserved.
//

#import "ODOperation.h"

@interface ODUserLogoutOperation : ODOperation

@property (nonatomic, copy) void (^logoutCompletionBlock)(NSError *error);

@end
