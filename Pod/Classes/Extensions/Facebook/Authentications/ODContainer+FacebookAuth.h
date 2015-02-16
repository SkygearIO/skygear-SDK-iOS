//
//  ODContainer+FacebookAuth.h
//  askq
//
//  Created by Kenji Pa on 23/1/15.
//  Copyright (c) 2015 Rocky Chan. All rights reserved.
//

#import "ODContainer.h"

#import "ODUserRecordID.h"

@interface ODContainer (FacebookAuth)

- (void)loginWithFacebookAccessToken:(NSString *)accessToken
                      expirationDate:(NSDate *)expirationDate
                            fbUserID:(NSString *)userID
                   completionHandler:(void(^)(ODUserRecordID *recordID, NSDictionary *profileInfo, NSError *error))completionHandler;

- (void)linkUserRecordID:(ODUserRecordID *)userRecordID
     facebookAccessToken:(NSString *)accessToken
          expirationDate:(NSDate *)expirationDate
                fbUserID:(NSString *)userID
       completionHandler:(void(^)(ODUserRecordID *recordID, NSDictionary *profileInfo, NSError *error))completionHandler;
- (void)unlinkFacebookForUserRecordID:(ODUserRecordID *)userRecordID;

@end
