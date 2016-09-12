//
//  SKYChatRecord.m
//  Pods
//
//  Created by Andrew Chung on 6/7/16.
//
//

#import "SKYChatRecord.h"

@implementation SKYChatRecord
+ (instancetype)recordWithRecord:(SKYRecord *)record{
    return [[[self alloc] initWithRecordID:record.recordID data:record.dictionary] initWithRecordData:record];
}

- (id)initWithRecordData:(SKYRecord *)record{
    self.ownerUserRecordID = record.ownerUserRecordID;
    self.creationDate = record.creationDate;
    self.creatorUserRecordID = record.creatorUserRecordID;
    self.modificationDate = record.modificationDate;
    self.lastModifiedUserRecordID = record.lastModifiedUserRecordID;
    self.accessControl = record.accessControl;
    self.recordID = record.recordID;
    return self;
}
@end
