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

@implementation SKYUserConversation

+ (instancetype)recordWithRecord:(SKYRecord *)record{
    return [[super recordWithRecord:record] assignVariableInTransientWithRecord:record];
}

- (id)assignVariableInTransientWithRecord:(SKYRecord *)record{
    SKYRecord *userRecord = [record.transient valueForKey:@"user"];
    SKYRecord *conversationRecord = [record.transient valueForKey:@"conversation"];
    if (userRecord) {
        self.user = [SKYChatUser recordWithRecord:userRecord];
    }
    if (conversationRecord) {
        self.conversation = [SKYConversation recordWithRecord:conversationRecord];

    }
    return self;
//    self.user =
}

@end
