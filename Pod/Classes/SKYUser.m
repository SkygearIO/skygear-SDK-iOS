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
#import "SKYDataSerialization.h"
#import "SKYUserDeserializer.h"
#import "SKYUser_Private.h"

#import "SKYQueryOperation.h"

@implementation SKYUser {
    NSMutableArray<SKYRole *> *_roles;
}

+ (instancetype)userWithUserID:(NSString *)userID
{
    return [[self alloc] initWithUserID:userID];
}

+ (instancetype)userWithResponse:(NSDictionary *)response
{
    return [[SKYUserDeserializer deserializer] userWithDictionary:response];
}

- (instancetype)initWithUserID:(NSString *)userID
{
    self = [super init];
    if (self) {
        _userID = [userID copy];
        _roles = [NSMutableArray array];
    }
    return self;
}

- (NSArray<SKYRole *> *)roles
{
    return [_roles copy];
}

- (void)setRoles:(NSArray *)roles
{
    _roles = [roles mutableCopy];
}

- (void)addRole:(SKYRole *)aRole
{
    if (![self hasRole:aRole]) {
        [_roles addObject:aRole];
    }
}

- (void)removeRole:(SKYRole *)aRole
{
    NSUInteger idx = [self indexOfRole:aRole];
    if (idx != NSNotFound) {
        [_roles removeObjectAtIndex:idx];
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
