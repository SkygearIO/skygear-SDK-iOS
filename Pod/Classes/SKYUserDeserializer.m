//
//  SKYUserDeserializer.m
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

#import "SKYUserDeserializer.h"

@implementation SKYUserDeserializer

+ (instancetype)deserializer
{
    return [[self alloc] init];
}

- (SKYUser *)userWithDictionary:(NSDictionary *)dictionary
{
    SKYUser *user = nil;

    NSString *userID = dictionary[@"_id"];
    if (userID.length) {
        user = [[SKYUser alloc] initWithUserID:userID];
        user.email = dictionary[@"email"];
        user.authData = dictionary[@"authData"];

        NSMutableArray<SKYRole *> *roles = [[NSMutableArray alloc] init];
        NSArray<NSString *> *roleNames = dictionary[@"roles"];
        [roleNames enumerateObjectsUsingBlock:^(NSString *perName, NSUInteger idx, BOOL *stop) {
            [roles addObject:[SKYRole roleWithName:perName]];
        }];

        user.roles = roles;
    }

    return user;
}

@end
