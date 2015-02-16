//
//  ODNewsfeedItem.m
//  askq
//
//  Created by Kenji Pa on 3/2/15.
//  Copyright (c) 2015 Rocky Chan. All rights reserved.
//

#import "ODNewsfeedItem.h"

NSString * const ODRecordTypeNewsfeedItem = @"_NewsfeedItem";

@implementation ODNewsfeedItem

- (instancetype)init {
    return [self initWithRecordID:nil];
}

- (instancetype)initWithRecordID:(ODRecordID *)recordID {
    self = [super initWithRecordType:ODRecordTypeNewsfeedItem recordID:recordID];
    return self;
}

@end
