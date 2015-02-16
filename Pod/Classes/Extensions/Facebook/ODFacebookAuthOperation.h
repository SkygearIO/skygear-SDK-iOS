//
//  ODFacebookAuthOperation.h
//  askq
//
//  Created by Kenji Pa on 23/1/15.
//  Copyright (c) 2015 Rocky Chan. All rights reserved.
//

#import "ODOperation.h"

@interface ODFacebookAuthOperation : ODOperation

@property (nonatomic, readonly) NSString *accessToken;
@property (nonatomic, readonly) NSDate *expirationDate;
@property (nonatomic, readonly) NSString *facebookUserID;

@end
