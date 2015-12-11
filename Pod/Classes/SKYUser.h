//
//  SKYUser.h
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

#import "SKYRecord.h"

#import "SKYUserRecordID.h"

@class SKYQueryCursor;
@class SKYQueryOperation;

@interface SKYUser : NSObject

- (instancetype)init NS_UNAVAILABLE;

- (instancetype)initWithUserRecordID:(SKYUserRecordID *)recordID;

+ (instancetype)userWithUserRecordID:(SKYUserRecordID *)recordID;

/**
 * The properties username, email, authData and isNew will be delegated to
 * their corresponding methods on SKYUserRecordID
 */
@property (nonatomic, readonly, copy) NSString *username;
@property (nonatomic, readonly, copy) NSString *email;
@property (nonatomic, readonly, copy) NSDictionary *authData;
@property (nonatomic, readonly, assign) BOOL isNew;

@property (nonatomic, readonly, copy) SKYUserRecordID *recordID;

@end
