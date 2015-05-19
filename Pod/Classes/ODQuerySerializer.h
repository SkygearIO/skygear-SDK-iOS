//
//  ODPredicateSerializer.h
//  Pods
//
//  Created by Patrick Cheung on 14/3/15.
//
//

#import <Foundation/Foundation.h>
#import "ODQuery.h"

@interface ODQuerySerializer : NSObject

+ (instancetype)serializer;
- (id)serializeWithQuery:(ODQuery *)query;
- (id)serializeWithExpression:(NSExpression *)expression;
- (id)serializeWithPredicate:(NSPredicate *)predicate;
- (id)serializeWithSortDescriptors:(NSArray *)sortDescriptors;

@end
