//
//  ODRecordChange.m
//  Pods
//
//  Created by atwork on 4/5/15.
//
//

#import "ODRecordChange.h"
#import "ODRecord.h"
#import "ODRecordChange_Private.h"

@implementation ODRecordChange

- (instancetype)initWithRecord:(ODRecord *)record
                action:(ODRecordChangeAction)action
         resolveMethod:(ODRecordResolveMethod)resolveMethod
      attributesToSave:(NSDictionary *)attributesToSave
{
    self = [self init];
    if (self) {
        _recordID = [record.recordID copy];
        _action = action;
        _resolveMethod = resolveMethod;
        _attributesToSave = [attributesToSave copy];
    }
    return self;
}

@end