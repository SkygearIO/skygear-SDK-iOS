//
//  SKYUser.m
//  SkyKit
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

#import "SKYUser.h"

#import "SKYQueryOperation.h"

@interface SKYUser ()

@property (nonatomic, readwrite, copy) SKYUserRecordID *recordID;

@end

@implementation SKYUser

- (instancetype)initWithUserRecordID:(SKYUserRecordID *)recordID
{
    self = [super init];
    if (self) {
        _recordID = [recordID copy];
    }
    return self;
}

+ (instancetype)userWithUserRecordID:(SKYUserRecordID *)recordID
{
    return [[self alloc] initWithUserRecordID:recordID];
}

- (NSString *)username
{
    return self.recordID.username;
}

- (NSString *)email
{
    return self.recordID.email;
}

- (NSDictionary *)authData
{
    return self.recordID.authData;
}

- (SKYUserRecordID *)recordID
{
    return _recordID;
}

@end
