//
//  ODUserRecordID.h
//  askq
//
//  Created by Kenji Pa on 22/1/15.
//  Copyright (c) 2015 Rocky Chan. All rights reserved.
//

#import "ODRecordID.h"

@interface ODUserRecordID : ODRecordID

- (instancetype)init NS_UNAVAILABLE;

@property (nonatomic, readonly, copy) NSString *username;
@property (nonatomic, readonly, copy) NSString *email;

/*
 Each key-value is expected to be storing authenication data of
 one 3rd-party authentication methods (e.g. Facebook, Twitter).

 For example, the data of this field for an user that has only
 authenticated by Facebook might look like this:
 {
    "facebook": {
        "accessToken": "FACEBOOK_ACCESS_TOKEN_HERE",
        "expirationDate":"1997-6-30T00:0:0.000",
        "id":"100000046709394"
    }
 }
 
 Implementor of 3rd-party authentication method is free to
 design their own data structure stored behind their key.
 */
@property (nonatomic, readonly, copy) NSDictionary *authData;

// denote whether this user record id is newly created from a request
// it is only set to be after an user record ID is created from authentication
@property (nonatomic, readonly, assign) BOOL isNew;

@end
