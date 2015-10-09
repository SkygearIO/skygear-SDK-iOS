//
//  SKYNewsfeedItem.h
//  askq
//
//  Created by Kenji Pa on 3/2/15.
//  Copyright (c) 2015 Rocky Chan. All rights reserved.
//

#import "SKYRecord.h"

extern NSString * const SKYRecordTypeNewsfeedItem;

// NOTE: Sounds problematic? Does it share the same database with other SKYRecords?
// What if we fetch / save the recordID obtained from an SKYNewsfeedItem?
@interface SKYNewsfeedItem : SKYRecord

- (instancetype)initWithRecordType:(NSString *)recordType NS_UNAVAILABLE;
- (instancetype)initWithRecordType:(NSString *)recordType recordID:(SKYRecordID *)recordID NS_UNAVAILABLE;
- (instancetype)initWithRecordID:(SKYRecordID *)recordID;

@end
