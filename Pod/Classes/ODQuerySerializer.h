//
//  ODPredicateSerializer.h
//  Pods
//
//  Created by Patrick Cheung on 14/3/15.
//
//

#import <Foundation/Foundation.h>

@interface ODQuerySerializer : NSObject

+ (instancetype)serializer;
- (id)serializeWithExpression:(NSExpression *)expression;
- (id)serializeWithPredicate:(NSPredicate *)predicate;
- (id)serializeWithSortDescriptors:(NSArray *)sortDescriptors;

@end
