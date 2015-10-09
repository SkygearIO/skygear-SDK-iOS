//
//  SKYPredicateSerializer.h
//  Pods
//
//  Created by Patrick Cheung on 14/3/15.
//
//

#import <Foundation/Foundation.h>
#import "SKYQuery.h"

@interface SKYQuerySerializer : NSObject

+ (instancetype)serializer;
- (id)serializeWithQuery:(SKYQuery *)query;
- (id)serializeWithExpression:(NSExpression *)expression;
- (id)serializeWithPredicate:(NSPredicate *)predicate;
- (id)serializeWithSortDescriptors:(NSArray *)sortDescriptors;

@end
