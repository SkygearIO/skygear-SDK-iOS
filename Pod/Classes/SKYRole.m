//
//  SKYRole.m
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

#import "SKYRole.h"

@interface SKYRole ()

@property (strong, nonatomic, readwrite) NSString *name;

@end

@implementation SKYRole

+ (NSMutableDictionary<NSString *, SKYRole *> *)definedRoles
{
    static NSMutableDictionary<NSString *, SKYRole *> *_definedRoles;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _definedRoles = [[NSMutableDictionary alloc] init];
    });

    return _definedRoles;
}

+ (instancetype)roleWithName:(NSString *)name
{
    SKYRole *role = [[SKYRole definedRoles] objectForKey:name];
    if (!role) {
        role = [[SKYRole alloc] initWithName:name];
        [[SKYRole definedRoles] setObject:role forKey:name];
    }

    return role;
}

- (instancetype)initWithName:(NSString *)name
{
    self = [super init];
    if (self) {
        self.name = name;
    }

    return self;
}

// override
- (NSString *)description
{
    return
        [NSString stringWithFormat:@"%@ { name = %@ }", NSStringFromClass(self.class), self.name];
}

// override
- (BOOL)isEqual:(id)object
{
    if (self == object) {
        return YES;
    }

    if (![object isKindOfClass:[SKYRole class]]) {
        return NO;
    }

    SKYRole *anotherRole = (SKYRole *)object;
    return [self.name isEqualToString:anotherRole.name];
}

#pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.name forKey:@"name"];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    return
        [[self class] roleWithName:[aDecoder decodeObjectOfClass:[NSString class] forKey:@"name"]];
}

@end
