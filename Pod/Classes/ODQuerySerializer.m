//
//  ODPredicateSerializer.m
//  Pods
//
//  Created by Patrick Cheung on 14/3/15.
//
//

#import "ODQuerySerializer.h"
#import "ODRecordSerialization.h"
#import "ODReference.h"
#import "ODDataSerialization.h"

@implementation ODQuerySerializer

+ (instancetype)serializer
{
    return [[ODQuerySerializer alloc] init];
}

- (NSString *)nameWithPredicateOperatorType:(NSPredicateOperatorType)operatorType
{
    switch (operatorType) {
        case NSEqualToPredicateOperatorType:
            return @"eq";
        case NSGreaterThanPredicateOperatorType:
            return @"gt";
        case NSGreaterThanOrEqualToPredicateOperatorType:
            return @"gte";
        case NSLessThanPredicateOperatorType:
            return @"lt";
        case NSLessThanOrEqualToPredicateOperatorType:
            return @"lte";
        case NSNotEqualToPredicateOperatorType:
            return @"neq";
        default:
            @throw [NSException exceptionWithName:NSInvalidArgumentException
                                           reason:[NSString stringWithFormat:@"Given NSPredicateOperatorType `%u` is not supported.", (unsigned int)operatorType]
                                         userInfo:nil];
            break;
    }
}

- (NSString *)nameWithCompoundPredicateType:(NSCompoundPredicateType)predicateType
{
    switch (predicateType) {
        case NSAndPredicateType:
            return @"and";
        case NSOrPredicateType:
            return @"or";
        case NSNotPredicateType:
            return @"not";
        default:
            @throw [NSException exceptionWithName:NSInvalidArgumentException
                                           reason:[NSString stringWithFormat:@"Given NSCompoundPredicateType `%u` is not supported.", (unsigned int)predicateType]
                                         userInfo:nil];
            break;
    }
}

- (id)serializeWithQuery:(ODQuery *)query
{
    NSMutableDictionary *result = [NSMutableDictionary dictionary];
    result[@"record_type"] = query.recordType;
    if (query.predicate) {
        result[@"predicate"] = [self serializeWithPredicate:query.predicate];
    }
    if (query.sortDescriptors.count > 0) {
        result[@"sort"] = [self serializeWithSortDescriptors:query.sortDescriptors];
    }
    if (query.eagerLoadKeyPath) {
        NSArray *keys = [query.eagerLoadKeyPath componentsSeparatedByString:@"."];
        if ([keys count] > 1) {
            NSLog(@"Eager loading doesn't support key paths with length more than 1.");
        }
        if ([keys count] > 0) {
            result[@"eager"] = @[[self serializeWithExpression:
                                   [NSExpression expressionForKeyPath:keys[0]]]];
        }
    }
    return result;
}

- (id)serializeWithExpression:(NSExpression *)expression
{
    switch (expression.expressionType) {
        case NSKeyPathExpressionType:
            return @{
                     ODDataSerializationCustomTypeKey: @"keypath",
                     @"$val": expression.keyPath,
                     };
        case NSConstantValueExpressionType:
            return [ODDataSerialization serializeObject:expression.constantValue];
        default:
            @throw [NSException exceptionWithName:NSInvalidArgumentException
                                           reason:[NSString stringWithFormat:@"Given NSExpressionType `%u` is not supported.", (unsigned int)expression.expressionType]
                                         userInfo:nil];
            break;
    }
}

- (id)serializeWithPredicate:(NSPredicate *)predicate
{
    if ([predicate isKindOfClass:[NSComparisonPredicate class]]) {
        NSComparisonPredicate *comparison = (NSComparisonPredicate *)predicate;
        return @[[self nameWithPredicateOperatorType:[comparison predicateOperatorType]],
                 [self serializeWithExpression:[comparison leftExpression]],
                 [self serializeWithExpression:[comparison rightExpression]],
                 ];
    } else if ([predicate isKindOfClass:[NSCompoundPredicate class]]) {
        NSCompoundPredicate *compound = (NSCompoundPredicate *)predicate;
        NSMutableArray *result = [NSMutableArray arrayWithObject:[self nameWithCompoundPredicateType:compound.compoundPredicateType]];
        [[compound subpredicates] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            [result addObject:[self serializeWithPredicate:(NSPredicate *)obj]];
        }];
        return [result copy];
    } else if (!predicate) {
        return [NSArray array];
    } else {
        @throw [NSException exceptionWithName:NSInvalidArgumentException
                                       reason:[NSString stringWithFormat:@"The given predicate is neither a NSComparisonPredicate or NSCompoundPredicate. Given: %@", NSStringFromClass([predicate class])]
                                     userInfo:nil];
    }
}

- (id)serializeWithSortDescriptors:(NSArray *)sortDescriptors
{
    NSMutableArray *result = [NSMutableArray array];
    [sortDescriptors enumerateObjectsUsingBlock:^(NSSortDescriptor *obj, NSUInteger idx, BOOL *stop) {
        
        [result addObject:@[[self serializeWithExpression:[NSExpression expressionForKeyPath:obj.key]],
                            obj.ascending ? @"asc" : @"desc"]];
    }];
    return [result copy];
}

@end
