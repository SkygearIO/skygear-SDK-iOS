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

#import "SKYDataSerialization.h"
#import "SKYUser.h"

#import "SKYQueryOperation.h"

@interface SKYUser ()

@property (nonatomic, readwrite, copy) NSString *recordID;

@end

@implementation SKYUser

+ (instancetype)userWithUserID:(NSString *)userID
{
    return [[self alloc] initWithUserID:userID];
}

+ (instancetype)userWithResponse:(NSDictionary *)response
{
    SKYUser *user = [SKYUser userWithUserID:response
                     [@"user_id"]];
    user.email = response[@"email"];
    user.username = response[@"username"];
    user.lastLoginAt = [SKYDataSerialization dateFromString:response[@"last_login_at"]];
    user.lastSeenAt = [SKYDataSerialization dateFromString:response[@"last_seen_at"]];
    return user;
}

- (instancetype)initWithUserID:(NSString *)userID
{
    self = [super init];
    if (self) {
        _userID = [userID copy];
    }
    return self;
}

- (void)addRole:(SKYRole *)aRole
{
    if (![self hasRole:aRole]) {
        NSMutableArray<SKYRole *> *roles = [self.roles mutableCopy];
        [roles addObject:aRole];

        [self setRoles:roles];
    }
}

- (void)removeRole:(SKYRole *)aRole
{
    NSUInteger idx = [self indexOfRole:aRole];
    if (idx != NSNotFound) {
        NSMutableArray<SKYRole *> *roles = [self.roles mutableCopy];
        [roles removeObjectAtIndex:idx];

        [self setRoles:roles];
    }
}

- (BOOL)hasRole:(SKYRole *)aRole
{
    return [self indexOfRole:aRole] != NSNotFound;
}

- (NSUInteger)indexOfRole:(SKYRole *)aRole
{
    __block NSUInteger foundIndex = NSNotFound;
    [self.roles enumerateObjectsUsingBlock:^(SKYRole *perRole, NSUInteger idx, BOOL *stop) {
        if ([perRole isEqual:aRole]) {
            *stop = YES;
            foundIndex = idx;
        }
    }];

    return foundIndex;
}

@end
