//
//  SKYUserRecordID.h
//  SKYKit
//
//  Copyright 2015 Oursky Ltd.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

#import "SKYRecordID.h"

@interface SKYUserRecordID : SKYRecordID

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithRecordType:(NSString *)type NS_UNAVAILABLE;
- (instancetype)initWithRecordType:(NSString *)type name:(NSString *)recordName NS_UNAVAILABLE;

- (BOOL)isEqualToUserRecordID:(SKYUserRecordID *)recordID;

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
