//
//  ODFacebookLinkageOperation.h
//  askq
//
//  Created by Kenji Pa on 23/1/15.
//  Copyright (c) 2015 Rocky Chan. All rights reserved.
//

#import "ODFacebookAuthOperation.h"

#import "ODUserRecordID.h"

typedef enum : NSInteger {
    ODFacebookLink = 1,
    ODFacebookUnlink = 2,
} ODFacebookLinkageAction;

@interface ODFacebookLinkageOperation : ODFacebookAuthOperation

- (instancetype)initWithUserRecordIDToLink:(ODUserRecordID *)userRecordID
                               accessToken:(NSString *)accessToken
                            expirationDate:(NSDate *)expirationDate
                            facebookUserID:(NSString *)userID;

- (instancetype)initWithUserRecordIDToUnlink:(ODUserRecordID *)userRecordID;

@property (nonatomic, readonly) ODFacebookLinkageAction action;

@property (nonatomic, copy) void (^linkageCompletionBlock)(ODUserRecordID *userRecordID, NSDictionary *profileInfo, NSError *error);

@end
