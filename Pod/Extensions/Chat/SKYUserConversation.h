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

@interface SKYUserConversation : SKYChatRecord

@property (strong, nonatomic) SKYChatUser* user;
@property (strong, nonatomic) SKYConversation* conversation;


@end
