//
//  SKYFacebookLoginOperation.h
//  askq
//
//  Created by Kenji Pa on 23/1/15.
//  Copyright (c) 2015 Rocky Chan. All rights reserved.
//

#import "SKYFacebookAuthOperation.h"

#import "SKYUserRecordID.h"

@interface SKYFacebookLoginOperation : SKYFacebookAuthOperation

- (instancetype)initWithAccessToken:(NSString *)accessToken expirationDate:(NSDate *)expirationDate facebookUserID:(NSString *)userID;

// profileInfo is the profile dictionary obtained via Facebook Graph API (i.e. "/me")
@property (nonatomic, copy) void (^loginCompletionBlock)(SKYUserRecordID *recordID, NSDictionary *profileInfo, NSError *error);

@end
