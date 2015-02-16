//
//  ODNewsfeedItem.h
//  askq
//
//  Created by Kenji Pa on 3/2/15.
//  Copyright (c) 2015 Rocky Chan. All rights reserved.
//

#import "ODRecord.h"

extern NSString * const ODRecordTypeNewsfeedItem;

// NOTE: Sounds problematic? Does it share the same database with other ODRecords?
// What if we fetch / save the recordID obtained from an ODNewsfeedItem?
@interface ODNewsfeedItem : ODRecord

- (instancetype)initWithRecordType:(NSString *)recordType NS_UNAVAILABLE;
- (instancetype)initWithRecordType:(NSString *)recordType recordID:(ODRecordID *)recordID NS_UNAVAILABLE;
- (instancetype)initWithRecordID:(ODRecordID *)recordID;

@end
