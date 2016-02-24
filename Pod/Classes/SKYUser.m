//
//  SKYUser.m
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

#import "SKYUser.h"

#import "SKYQueryOperation.h"

@interface SKYUser ()

@property (nonatomic, readwrite, copy) NSString *recordID;

@end

@implementation SKYUser

- (instancetype)initWithUserID:(NSString *)userID
{
    self = [super init];
    if (self) {
        _userID = [userID copy];
    }
    return self;
}

+ (instancetype)userWithUserID:(NSString *)userID
{
    return [[self alloc] initWithUserID:userID];
}

@end
