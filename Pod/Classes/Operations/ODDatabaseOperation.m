//
//  ODDatabaseOperation.m
//  askq
//
//  Created by Kenji Pa on 21/1/15.
//  Copyright (c) 2015 Rocky Chan. All rights reserved.
//

#import "ODDatabaseOperation.h"

@implementation ODDatabaseOperation

- (void)operationWillStart
{
    [super operationWillStart];
    if (![self database]) {
        @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                       reason:@"The operation being started does not have a ODDatabase set to the `database` property."
                                     userInfo:nil];
    }
}


@end
