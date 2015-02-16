//
//  ODPushNewsfeedOperation.h
//  askq
//
//  Created by Kenji Pa on 23/1/15.
//  Copyright (c) 2015 Rocky Chan. All rights reserved.
//

#import "ODDatabaseOperation.h"

#import "ODNewsfeed.h"
#import "ODReference.h"
#import "ODRecord.h"

@interface ODPushNewsfeedOperation : ODDatabaseOperation

- (instancetype)initWithRecord:(ODRecord *)record
            pushingToReference:(ODReference *)reference
                   forNewsfeed:(ODNewsfeed *)newsfeed;

- (instancetype)initWithRecords:(NSArray *)records
             pushingToReference:(ODReference *)reference
                    forNewsfeed:(ODNewsfeed *)newsfeed;

// seems pushing to a ODQuery is also desirable?

@property (strong, nonatomic) ODNewsfeed *newsfeed;
@property (nonatomic, copy) NSArray *records;
// reference to push to
@property (nonatomic, copy) ODReference *reference;

@end
