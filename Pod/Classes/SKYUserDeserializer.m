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
#import "SKYDataSerialization.h"
#import "SKYUser_Private.h"

@implementation SKYUserDeserializer

+ (instancetype)deserializer
{
    return [[self alloc] init];
}

/**
 Returns the User ID from the dictionary.

 The key of the User ID can be different, depending on which server action was called to
 return data. This method will look for `_id` and `user_id` keys before returning nil if
 no such keys are found.
 */
- (NSString *)userIDWithDictionary:(NSDictionary *)dictionary
{

    NSString *userID = dictionary[@"_id"];
    if (userID) {
        return userID;
    }

    userID = dictionary[@"user_id"];
    if (userID) {
        return userID;
    }

    return nil;
}

- (SKYUser *)userWithDictionary:(NSDictionary *)dictionary
{
    SKYUser *user = nil;

    NSString *userID = [self userIDWithDictionary:dictionary];
    if (userID.length) {
        user = [[SKYUser alloc] initWithUserID:userID];
        user.email = dictionary[@"email"];
        user.username = dictionary[@"username"];
        user.authData = dictionary[@"authData"];
        if (dictionary[@"last_login_at"]) {
            user.lastLoginAt = [SKYDataSerialization dateFromString:dictionary[@"last_login_at"]];
        }
        if (dictionary[@"last_seen_at"]) {
            user.lastSeenAt = [SKYDataSerialization dateFromString:dictionary[@"last_seen_at"]];
        }

        // Parse roles
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
