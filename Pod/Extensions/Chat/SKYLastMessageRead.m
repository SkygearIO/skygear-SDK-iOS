//
//  SkyLastMessageRead.m
//  Pods
//
//  Created by Andrew Chung on 6/2/16.
//
//

#import "SKYLastMessageRead.h"

@implementation SKYLastMessageRead

- (id)init{
    return [SKYRecord recordWithRecordType:@"last_message_read"];
}

- (void)setConversationId:(NSString *)conversationId{
    self[@"conversation_id"] = conversationId;
}

- (NSString *)conversationId{
    return self[@"conversation_id"];
}

- (void)setMessageId:(NSString *)messageId{
    self[@"message_id"] = messageId;
}

- (NSString *)messageId{
    return self[@"message_id"];
}

@end
