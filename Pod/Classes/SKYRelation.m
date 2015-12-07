//
//  SKYRelation.m
//  Pods
//
//  Created by Kenji Pa on 2/6/15.
//
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

@end
