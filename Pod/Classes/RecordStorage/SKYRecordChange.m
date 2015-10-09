//
//  SKYRecordChange.m
//  Pods
//
//  Created by atwork on 4/5/15.
//
//

#import "SKYRecordChange.h"
#import "SKYRecord.h"
#import "SKYRecordChange_Private.h"

@implementation SKYRecordChange

- (instancetype)initWithRecord:(SKYRecord *)record
                        action:(SKYRecordChangeAction)action
                 resolveMethod:(SKYRecordResolveMethod)resolveMethod
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

- (instancetype)initWithRecordID:(SKYRecordID *)recordID
                          action:(SKYRecordChangeAction)action
                   resolveMethod:(SKYRecordResolveMethod)resolveMethod
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
        _finished = [aDecoder decodeBoolForKey:@"finished"];
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
    [aCoder encodeInteger:_finished forKey:@"finished"];
    [aCoder encodeInteger:_resolveMethod forKey:@"resolveMethod"];
    [aCoder encodeObject:_error forKey:@"error"];
}

@end
