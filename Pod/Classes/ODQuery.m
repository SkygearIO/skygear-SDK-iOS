//
//  ODQuery.m
//  askq
//
//  Created by Kenji Pa on 21/1/15.
//  Copyright (c) 2015 Rocky Chan. All rights reserved.
//

#import "ODQuery.h"

@implementation ODQuery

- (instancetype)initWithRecordType:(NSString *)recordType
                         predicate:(NSPredicate *)predicate {
    self = [super init];
    if (self) {
        _recordType = recordType;
        _predicate = predicate;
    }
    return self;
}

@end
