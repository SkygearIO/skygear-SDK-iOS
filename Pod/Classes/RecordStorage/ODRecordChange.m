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

- (instancetype)initWithRecordID:(ODRecordID *)recordID
                          action:(ODRecordChangeAction)action
                   resolveMethod:(ODRecordResolveMethod)resolveMethod
                attributesToSave:(NSDictionary *)attributesToSave
{
    self = [self init];
    if (self) {
        _recordID = [recordID copy];
        _action = action;
        _resolveMethod = resolveMethod;
        _attributesToSave = [attributesToSave copy];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [self init];
    if (self) {
        _recordID = [aDecoder decodeObjectForKey:@"recordID"];
        _attributesToSave = [aDecoder decodeObjectForKey:@"attributesToSave"];
        _action = [aDecoder decodeIntegerForKey:@"action"];
        _state = [aDecoder decodeIntegerForKey:@"state"];
        _resolveMethod = [aDecoder decodeIntegerForKey:@"resolveMethod"];
        _error = [aDecoder decodeObjectForKey:@"error"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:_recordID forKey:@"recordID"];
    [aCoder encodeObject:_attributesToSave forKey:@"attributesToSave"];
    [aCoder encodeInteger:_action forKey:@"action"];
    [aCoder encodeInteger:_state forKey:@"state"];
    [aCoder encodeInteger:_resolveMethod forKey:@"resolveMethod"];
    [aCoder encodeObject:_error forKey:@"error"];
}

@end