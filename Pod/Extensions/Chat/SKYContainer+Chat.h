//
//  SKYContainer+Chat.h
//  SKYKit
//
//  Copyright 2016 Oursky Ltd.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.

#import "SKYKit.h"
typedef NS_ENUM(int, SKYChatMetaDataType) {
    SKYChatMetaDataImage,
    SKYChatMetaDataVoice,
    SKYChatMetaDataText
};

NSString *const SKYChatMetaDataAssetNameImage = @"message-image";
NSString *const SKYChatMetaDataAssetNameVoice = @"message-voice";

@class FBSDKAccessToken, SKYConversation, SKYConversationChange, SKYMessage, SKYUserChannel, SKYLastMessageRead,SKYChatUser,SKYUserConversation;



@interface SKYContainer (Chat)
typedef void (^SKYContainerConversationOperationActionCompletion)(SKYConversation *conversation, NSError *error);
typedef void (^SKYContainerMessageOperationActionCompletion)(SKYMessage *message, NSError *error);
typedef void (^SKYContainerMarkLastMessageReadOperationActionCompletion)(SKYUserConversation *conversation, NSError *error);
typedef void (^SKYContainerLastMessageReadOperationActionCompletion)(SKYLastMessageRead *lastMessageRead, NSError *error);
typedef void (^SKYContainerTotalUnreadCountOperationActionCompletion)(NSDictionary *response, NSError *error);
typedef void (^SKYContainerUnreadCountOperationActionCompletion)(NSInteger count, NSError *error);
typedef void (^SKYContainerChannelOperationActionCompletion)(SKYUserChannel *userChannel, NSError *error);
typedef void (^SKYContainerGetAgentListActionCompletion)(NSArray<SKYChatUser*> *agentListArray, NSError *error);
typedef void (^SKYContainerGetConversationListActionCompletion)(NSArray<SKYUserConversation*> *conversationList, NSError *error);
typedef void (^SKYContainerGetMessagesActionCompletion)(NSArray<SKYMessage*> *messageList, NSError *error);
typedef void (^SKYContainerGetAssetsActionCompletion)(SKYAsset *assets, NSError *error);


/**
 Login a facebook user.
 */
- (void)loginWithFacebookAccessToken:(FBSDKAccessToken *)accessToken
                   completionHandler:(SKYContainerUserOperationActionCompletion)completionHandler;
- (void)createConversationWithParticipantIds:(NSArray *)participantIds withAdminIds:(NSArray *)adminIds withTitle:(NSString *)title completionHandler:(SKYContainerConversationOperationActionCompletion)completionHandler;
- (void)getOrCreateDirectConversationWithuUserId:(NSString *)userId completionHandler:(SKYContainerConversationOperationActionCompletion)completionHandler;
- (void)getConversationWithConversationId:(NSString *)conversationId completionHandler:(SKYContainerConversationOperationActionCompletion)completionHandler;
- (void)getConversationsCompletionHandler:(SKYContainerGetConversationListActionCompletion)completionHandler;
- (void)deleteConversationWithConversationId:(NSString *)conversationId completionHandler:(SKYContainerConversationOperationActionCompletion)completionHandler;
- (void)updateConversationWithConversationId:(NSString *)conversationId withChange:(SKYConversationChange *)change completionHandler:(SKYContainerConversationOperationActionCompletion)completionHandler;
- (void)addParticipantsWithConversationId:(NSString *)conversationId withParticipantIds:(NSArray<NSString*> *)participantIds  completionHandler:(SKYContainerConversationOperationActionCompletion)completionHandler;
- (void)removeParticipantsWithConversationId:(NSString *)conversationId withParticipantIds:(NSArray<NSString*> *)participantIds  completionHandler:(SKYContainerConversationOperationActionCompletion)completionHandler;
- (void)addAdminsWithConversationId:(NSString *)conversationId withAdminIds:(NSMutableArray *)adminIds  completionHandler:(SKYContainerConversationOperationActionCompletion)completionHandler;
- (void)removeAdminWithConversationId:(NSString *)conversationId withAdminIds:(NSMutableArray *)adminIds  completionHandler:(SKYContainerConversationOperationActionCompletion)completionHandler;
//-(void)createMessageWithConversationId:(NSString *)conversationId withBody:(NSString *)body withMetadata:(id)metadata completionHandler:(SKYContainerMessageOperationActionCompletion)completionHandler;//not finished

-(void)createMessageWithConversationId:(NSString *)conversationId withBody:(NSString *)body withURL:(NSURL *)url withType:(SKYChatMetaDataType)type withDuration:(float)duration completionHandler:(SKYContainerMessageOperationActionCompletion)completionHandler;//not finished
-(void)createMessageWithConversationId:(NSString *)conversationId withBody:(NSString *)body withImages:(UIImage *)image withType:(SKYChatMetaDataType)type completionHandler:(SKYContainerMessageOperationActionCompletion)completionHandler;//not finished
- (void)createMessageWithSKYMessage:(SKYMessage *)message completionHandler:(SKYContainerMessageOperationActionCompletion)completionHandler;


- (void)getMessagesWithConversationId:(NSString *)conversationId withLimit:(NSString *)limit withBeforeTime:(NSDate *)beforeTime completionHandler:(SKYContainerGetMessagesActionCompletion)completionHandler;

- (void)markAsLastMessageReadWithConversationId:(NSString *)conversationId withMessageId:(NSString *)messageId completionHandler:(SKYContainerMarkLastMessageReadOperationActionCompletion)completionHandler;
- (void)getOrCreateLastMessageReadithConversationId:(NSString *)conversationId completionHandler:(SKYContainerLastMessageReadOperationActionCompletion)completionHandler;
- (void)getTotalUnreadCount:(SKYContainerTotalUnreadCountOperationActionCompletion)completionHandler;
- (void)getUnreadMessageCountWithConversationId:(NSString *)conversationId completionHandler:(SKYContainerUnreadCountOperationActionCompletion)completionHandler;

- (void)getOrCreateUserChannelCompletionHandler:(SKYContainerChannelOperationActionCompletion)completionHandler;
- (void)subscribeHandler:(void (^)(NSDictionary *dictionary))messageHandler;
- (void)fetchAssetsByRecordId:(NSString *)recordId CompletionHandler:(SKYContainerGetAssetsActionCompletion)completionHandler;

@end
