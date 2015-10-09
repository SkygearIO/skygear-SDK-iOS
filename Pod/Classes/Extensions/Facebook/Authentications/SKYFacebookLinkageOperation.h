//
//  SKYFacebookLinkageOperation.h
//  askq
//
//  Created by Kenji Pa on 23/1/15.
//  Copyright (c) 2015 Rocky Chan. All rights reserved.
//

#import "SKYFacebookAuthOperation.h"

#import "SKYUserRecordID.h"

typedef enum : NSInteger {
    SKYFacebookLink = 1,
    SKYFacebookUnlink = 2,
} SKYFacebookLinkageAction;

@interface SKYFacebookLinkageOperation : SKYFacebookAuthOperation

- (instancetype)initWithUserRecordIDToLink:(SKYUserRecordID *)userRecordID
                               accessToken:(NSString *)accessToken
                            expirationDate:(NSDate *)expirationDate
                            facebookUserID:(NSString *)userID;

- (instancetype)initWithUserRecordIDToUnlink:(SKYUserRecordID *)userRecordID;

@property (nonatomic, readonly) SKYFacebookLinkageAction action;

@property (nonatomic, copy) void (^linkageCompletionBlock)(SKYUserRecordID *userRecordID, NSDictionary *profileInfo, NSError *error);

@end
