//
//  SkyLastMessageRead.h
//  Pods
//
//  Created by Andrew Chung on 6/2/16.
//
//

#import "SKYChatRecord.h"
#import <SKYKit/SKYKit.h>

@interface SKYLastMessageRead : SKYChatRecord
@property (strong, nonatomic) NSString *conversationId;
@property (strong, nonatomic) NSString *messageId;

+ (instancetype)recordWithLastMessageReadRecordType;

@end
