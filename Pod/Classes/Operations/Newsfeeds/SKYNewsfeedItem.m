//
//  SKYNewsfeedItem.m
//  askq
//
//  Created by Kenji Pa on 3/2/15.
//  Copyright (c) 2015 Rocky Chan. All rights reserved.
//

#import "SKYNewsfeedItem.h"

NSString * const SKYRecordTypeNewsfeedItem = @"_NewsfeedItem";

@implementation SKYNewsfeedItem

- (instancetype)init {
    return [self initWithRecordID:nil];
}

- (instancetype)initWithRecordID:(SKYRecordID *)recordID {
    self = [super initWithRecordType:SKYRecordTypeNewsfeedItem recordID:recordID];
    return self;
}

@end
