//
//  SkyLastMessageRead.h
//  Pods
//
//  Created by Andrew Chung on 6/2/16.
//
//

#import <SKYKit/SKYKit.h>
#import "SKYChatRecord.h"

@interface SKYLastMessageRead : SKYChatRecord
@property (strong, nonatomic) NSString* conversationId;
@property (strong, nonatomic) NSString* messageId;

- (id)init;

@end
