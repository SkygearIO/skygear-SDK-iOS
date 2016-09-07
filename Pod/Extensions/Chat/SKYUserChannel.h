//
//  SKYUserChannel.h
//  Pods
//
//  Created by Andrew Chung on 6/2/16.
//
//

#import "SKYChatRecord.h"
#import <SKYKit/SKYKit.h>

@interface SKYUserChannel : SKYChatRecord
@property (strong, nonatomic) NSString *name;

+ (instancetype)recordWithUserChannelRecordType;

@end
