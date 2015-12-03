//
//  SKYRelationPredicate.m
//  Pods
//
//  Created by atwork on 3/12/2015.
//
//

#import "SKYRelationPredicate.h"
#import "SKYRelation.h"

@implementation SKYRelationPredicate

- (instancetype)init
{
    return [self initWithRelation:nil keyPath:nil];
}

- (instancetype)initWithRelation:(SKYRelation *)relation keyPath:(NSString *)keyPath
{
    if (self == [super init]) {
        _relation = relation;
        _keyPath = [keyPath copy];
    }
    return self;
}

+ (instancetype)predicateWithRelation:(SKYRelation *)relation keyPath:(NSString *)keyPath
{
    return [[SKYRelationPredicate alloc] initWithRelation:relation keyPath:keyPath];
}

@end
