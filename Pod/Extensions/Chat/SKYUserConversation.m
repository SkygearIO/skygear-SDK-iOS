//
//  SKYUserConversation.m
//  Pods
//
//  Created by Andrew Chung on 7/26/16.
//
//

#import "SKYUserConversation.h"
#import "SKYChatUser.h"
#import "SKYConversation.h"
#import "SKYMessage.h"

@implementation SKYUserConversation

+ (instancetype)recordWithRecord:(SKYRecord *)record
{
    return [[super recordWithRecord:record] assignVariableInTransientWithRecord:record];
}

- (id)assignVariableInTransientWithRecord:(SKYRecord *)record
{
    SKYRecord *userRecord = [record.transient valueForKey:@"user"];
    SKYRecord *conversationRecord = [record.transient valueForKey:@"conversation"];
    SKYRecord *lastReadMessage = [record.transient valueForKey:@"last_read_message"];
    if (userRecord != (id)[NSNull null]) {
        self.user = [SKYChatUser recordWithRecord:userRecord];
    }
    if (conversationRecord != (id)[NSNull null]) {
        self.conversation = [SKYConversation recordWithRecord:conversationRecord];
    }
    if (lastReadMessage != (id)[NSNull null]) {
        self.lastReadMessage = [SKYMessage recordWithRecord:lastReadMessage];
    }
    return self;
}

- (void)setUnreadCount:(NSNumber *)unreadCount
{
    self[@"unread_count"] = unreadCount;
}

- (NSNumber *)unreadCount
{
    return self[@"unread_count"];
}

@end
