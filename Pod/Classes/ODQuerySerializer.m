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
#import "ODLocationSortDescriptor.h"

@implementation ODQuerySerializer

+ (instancetype)serializer
{
    return [[ODQuerySerializer alloc] init];
}

- (NSString *)nameWithPredicateOperatorType:(NSPredicateOperatorType)operatorType andOptions:(NSComparisonPredicateOptions)options
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
        case NSLikePredicateOperatorType:
        case NSBeginsWithPredicateOperatorType:
        case NSEndsWithPredicateOperatorType:
        case NSContainsPredicateOperatorType:
            if (options&NSCaseInsensitivePredicateOption) {
                return @"ilike";
            } else {
                return @"like";
            }
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

- (BOOL)isStringMatchingPredicateOperatorType:(NSPredicateOperatorType)operatorType
{
    switch (operatorType) {
        case NSLikePredicateOperatorType:
        case NSBeginsWithPredicateOperatorType:
        case NSEndsWithPredicateOperatorType:
        case NSContainsPredicateOperatorType:
            return YES;
        default:
            return NO;
    }
}

- (id)serializeWithQuery:(ODQuery *)query
{
    NSMutableDictionary *result = [NSMutableDictionary dictionary];
    if (query.recordType.length) {
        result[@"record_type"] = query.recordType;
    }
    if (query.predicate) {
        result[@"predicate"] = [self serializeWithPredicate:query.predicate];
    }
    if (query.sortDescriptors.count > 0) {
        result[@"sort"] = [self serializeWithSortDescriptors:query.sortDescriptors];
    }
    __block NSMutableDictionary *include = nil;
    [query.transientIncludes enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        if (!include) {
            include = [NSMutableDictionary dictionary];
        }
        
        include[key] = [self serializeWithExpression:obj];
    }];
    if (include) {
        result[@"include"] = include;
    }
    if (query.offset > 0) {
        result[@"offset"] = @(query.offset);
    }
    if (query.limit > 0) {
        result[@"limit"] = @(query.limit);
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
        case NSFunctionExpressionType:
            return [self serializeWithFunctionExpression:expression];
        default:
            @throw [NSException exceptionWithName:NSInvalidArgumentException
                                           reason:[NSString stringWithFormat:@"Given NSExpressionType `%u` is not supported.", (unsigned int)expression.expressionType]
                                         userInfo:nil];
            break;
    }
}

- (id)serializeWithFunctionExpression:(NSExpression *)expression
{
    NSMutableArray *arr = [@[@"func"] mutableCopy];

    [arr addObject:remoteFunctionName(expression.function)];
    for (id obj in expression.arguments) {
        [arr addObject:[self serializeWithExpression:obj]];
    }

    return arr;
}

- (id)serializeWithPredicate:(NSPredicate *)predicate
{
    if ([predicate isKindOfClass:[NSComparisonPredicate class]]) {
        NSComparisonPredicate *comparison = (NSComparisonPredicate *)predicate;
        NSPredicateOperatorType operatorType = comparison.predicateOperatorType;
        NSExpression *lhs = [comparison leftExpression];
        NSExpression *rhs = [comparison rightExpression];
        
        if ([self isStringMatchingPredicateOperatorType:operatorType]) {
            NSMutableString *matchPattern = [[rhs constantValue] mutableCopy];
            switch (operatorType) {
                case NSBeginsWithPredicateOperatorType:
                    [matchPattern appendString:@"%"];
                    break;
                case NSEndsWithPredicateOperatorType:
                    [matchPattern insertString:@"%" atIndex:0];
                    break;
                case NSContainsPredicateOperatorType:
                    [matchPattern appendString:@"%"];
                    [matchPattern insertString:@"%" atIndex:0];
                    break;
                case NSLikePredicateOperatorType:
                    [matchPattern replaceOccurrencesOfString:@"?"
                                                  withString:@"_"
                                                     options:0
                                                       range:NSMakeRange(0, [matchPattern length])];
                    [matchPattern replaceOccurrencesOfString:@"*"
                                                  withString:@"%"
                                                     options:0
                                                       range:NSMakeRange(0, [matchPattern length])];
                    break;
                default:
                    @throw [NSException exceptionWithName:NSInvalidArgumentException
                                                   reason:@"Operator type is not supported."
                                                 userInfo:nil];
            }
            rhs = [NSExpression expressionForConstantValue:[matchPattern copy]];
        }
        return @[[self nameWithPredicateOperatorType:operatorType andOptions:comparison.options],
                 [self serializeWithExpression:lhs],
                 [self serializeWithExpression:rhs],
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
        if ([obj isKindOfClass:[ODLocationSortDescriptor class]]) {
            ODLocationSortDescriptor *sd = (ODLocationSortDescriptor *)obj;
            NSExpression *expr = [NSExpression expressionForFunction:@"distanceToLocation:fromLocation:"
                                                           arguments:@[[NSExpression expressionForKeyPath:sd.key],
                                                                       [NSExpression expressionForConstantValue:sd.relativeLocation]]];
            [result addObject:@[[self serializeWithExpression:expr], sd.ascending ? @"asc" : @"desc"]];
        } else {
            [result addObject:@[[self serializeWithExpression:[NSExpression expressionForKeyPath:obj.key]],
                                obj.ascending ? @"asc" : @"desc"]];
        }
    }];
    return [result copy];
}

@end
