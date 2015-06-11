//
//  ODRelation.m
//  Pods
//
//  Created by Kenji Pa on 2/6/15.
//
//

#import "ODRelation.h"

@interface ODRelation()

- (instancetype)initWithName:(NSString *)name NS_DESIGNATED_INITIALIZER;

+ (instancetype)relationWithName:(NSString *)name;

@property (nonatomic, readwrite, copy) NSString *name;

@end

@implementation ODRelation

- (instancetype)initWithName:(NSString *)name
{
    self = [super init];
    if (self) {
        _name = name;
    }
    return self;
}

+ (instancetype)relationWithName:(NSString *)name
{
    return [[self alloc] initWithName:name];
}

+ (instancetype)relationFollow
{
    static id shared;
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        shared = [self relationWithName:@"follow"];
    });
    return shared;
}

+ (instancetype)relationFriend
{
    static id shared;
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        shared = [self relationWithName:@"friend"];
    });
    return shared;
}

#pragma mark - NSObject

- (BOOL)isEqualToRelation:(ODRelation *)relation
{
    // NOTE(limouren): since all instances are singleton we could use simple comparison here
    return self == relation;
}

- (BOOL)isEqual:(id)object
{
    if (self == object) {
        return YES;
    }

    if (![object isKindOfClass:ODRelation.class]) {
        return NO;
    }

    return [self isEqualToRelation:object];
}

@end
