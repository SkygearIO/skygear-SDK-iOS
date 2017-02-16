//
//  SKYRecordChange.m
//  SKYKit
//
//  Copyright 2015 Oursky Ltd.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
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
