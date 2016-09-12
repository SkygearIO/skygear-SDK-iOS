//
//  SKYUserConversation.h
//  Pods
//
//  Created by Andrew Chung on 7/26/16.
//
//

#import "SKYChatRecord.h"
#import "SKYChatUser.h"
#import "SKYConversation.h"
#import "SKYMessage.h"

@interface SKYUserConversation : SKYChatRecord

@property (strong, nonatomic) SKYChatUser *user;
@property (strong, nonatomic) SKYConversation *conversation;
@property (strong, nonatomic) SKYMessage *lastReadMessage;
@property (assign, nonatomic) NSNumber *unreadCount;

@end
