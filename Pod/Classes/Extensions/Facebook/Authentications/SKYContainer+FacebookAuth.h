//
//  SKYContainer+FacebookAuth.h
//  askq
//
//  Created by Kenji Pa on 23/1/15.
//  Copyright (c) 2015 Rocky Chan. All rights reserved.
//

#import "SKYContainer.h"

#import "SKYUserRecordID.h"

@interface SKYContainer (FacebookAuth)

- (void)loginWithFacebookAccessToken:(NSString *)accessToken
                      expirationDate:(NSDate *)expirationDate
                            fbUserID:(NSString *)userID
                   completionHandler:(void(^)(SKYUserRecordID *recordID, NSDictionary *profileInfo, NSError *error))completionHandler;

- (void)linkUserRecordID:(SKYUserRecordID *)userRecordID
     facebookAccessToken:(NSString *)accessToken
          expirationDate:(NSDate *)expirationDate
                fbUserID:(NSString *)userID
       completionHandler:(void(^)(SKYUserRecordID *recordID, NSDictionary *profileInfo, NSError *error))completionHandler;
- (void)unlinkFacebookForUserRecordID:(SKYUserRecordID *)userRecordID;

@end
