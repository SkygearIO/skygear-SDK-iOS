//
//  SKYRelation.m
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

#import "SKYRelation.h"

@interface SKYRelation ()

- (instancetype)initWithName:(NSString *)name
                   direction:(SKYRelationDirection)direction NS_DESIGNATED_INITIALIZER;

@property (nonatomic, readwrite, copy) NSString *name;

@end

@implementation SKYRelation

- (instancetype)initWithName:(NSString *)name direction:(SKYRelationDirection)direction
{
    self = [super init];
    if (self) {
        if (![name isKindOfClass:[NSString class]]) {
            @throw [NSException exceptionWithName:NSInvalidArgumentException
                                           reason:@"Relation name is nil or of unexpected class."
                                         userInfo:nil];
        }
        _name = name;
        _direction = direction;
    }
    return self;
}

+ (instancetype)relationWithName:(NSString *)name direction:(SKYRelationDirection)direction
{
    if ([name isEqualToString:@"friend"] && direction == SKYRelationDirectionMutual) {
        return [self friendRelation];
    } else if ([name isEqualToString:@"follow"] && direction == SKYRelationDirectionOutward) {
        return [self followingRelation];
    } else if ([name isEqualToString:@"follow"] && direction == SKYRelationDirectionInward) {
        return [self followedRelation];
    }
    return [[self alloc] initWithName:name direction:direction];
}

+ (instancetype)friendRelation
{
    static id shared;
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        shared = [[self alloc] initWithName:@"friend" direction:SKYRelationDirectionMutual];
    });
    return shared;
}

+ (instancetype)followingRelation
{
    static id shared;
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        shared = [[self alloc] initWithName:@"follow" direction:SKYRelationDirectionOutward];
    });
    return shared;
}

+ (instancetype)followedRelation
{
    static id shared;
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        shared = [[self alloc] initWithName:@"follow" direction:SKYRelationDirectionInward];
    });
    return shared;
}

#pragma mark - NSObject

- (BOOL)isEqualToRelation:(SKYRelation *)relation
{
    return self == relation ||
           ([self.name isEqualToString:relation.name] && self.direction == relation.direction);
}

- (BOOL)isEqual:(id)object
{
    if (self == object) {
        return YES;
    }

    if (![object isKindOfClass:SKYRelation.class]) {
        return NO;
    }

    return [self isEqualToRelation:object];
}

- (NSUInteger)hash
{
    return [_name hash] ^ _direction;
}

#pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.name forKey:@"name"];
    [aCoder encodeInteger:self.direction forKey:@"direction"];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    return [self initWithName:[aDecoder decodeObjectOfClass:[NSString class] forKey:@"name"]
                    direction:[aDecoder decodeIntegerForKey:@"direction"]];
}

@end
