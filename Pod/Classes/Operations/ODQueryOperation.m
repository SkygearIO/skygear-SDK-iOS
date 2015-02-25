//
//  ODQueryOperation.m
//  askq
//
//  Created by Kenji Pa on 21/1/15.
//  Copyright (c) 2015 Rocky Chan. All rights reserved.
//

#import "ODQueryOperation.h"

#import "ODFollowQuery.h"

@interface ODQueryOperation()

@property ODQueryCursor *cursor;

@end

@implementation ODQueryOperation

- (instancetype)initWithQuery:(ODQuery *)query {
    self = [super init];
    if (self) {
        _query = query;
    }
    return self;
}

- (instancetype)initWithCursor:(ODQueryCursor *)cursor {
    self = [super init];
    if (self) {
        _cursor = cursor;
    }
    return self;
}

- (BOOL)isAsynchronous
{
    return NO;
}

- (void)main {
    if (self.recordFetchedBlock) {
        for (ODRecord *record in self.results) {
            self.recordFetchedBlock(record);
        }
    }

    if (self.queryCompletionBlock) {
        self.queryCompletionBlock(nil, nil);
    }
}

@end
