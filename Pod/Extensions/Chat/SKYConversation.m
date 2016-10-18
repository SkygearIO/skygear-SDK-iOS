//
//  Conversation.m
//  Pods
//
//  Created by Andrew Chung on 6/1/16.
//
//

#import "SKYConversation.h"

@implementation SKYConversation

+ (instancetype)recordWithRecord:(SKYRecord *)record
{
    return [super recordWithRecord:record];
}

- (void)setParticipantIds:(NSArray<NSString *> *)participantIds
{
    self[@"participant_ids"] = participantIds;
}

- (NSArray<NSString *> *)participantIds
{
    return self[@"participant_ids"];
}

- (void)setAdminIds:(NSArray<NSString *> *)adminIds
{
    self[@"admin_ids"] = adminIds;
}

- (NSArray<NSString *> *)adminIds
{
    return self[@"admin_ids"];
}

- (void)setTitle:(NSString *)title
{
    self[@"title"] = title;
}

- (NSString *)title
{
    return self[@"title"];
}

- (NSDate *)updatedDate
{
    return self.modificationDate;
}

- (NSString *)toString
{
    return [NSString stringWithFormat:@"SKYConversation Detail:\nparticipantIds: %@\nadminIds: "
                                      @"%@\ntitle: %@\nupdatedAt: %@",
                                      self.participantIds, self.adminIds, self.title,
                                      self.updatedDate];
}

- (NSString *)getOtherUserUserId:(NSString *)myUserId
{
    NSString *returnString = @"";
    for (NSString *userId in self.participantIds) {
        if (![myUserId isEqualToString:userId]) {
            returnString = userId;
            break;
        }
    }
    return returnString;
}

@end
