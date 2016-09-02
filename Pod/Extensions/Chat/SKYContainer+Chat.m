//
//  SKYContainer+Chat.m
//  SKYKit
//
//  Copyright 2015 Oursky Ltd.
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

#import "SKYContainer+Chat.h"
#import "SKYContainer_Private.h"
#import "SKYConversation.h"
#import "SKYKit.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import "SKYConversationChange.h"
#import "SKYMessage.h"
#import "SKYLastMessageRead.h"
#import "SKYUserChannel.h"
#import "SKYPubsub.h"
#import "SKYUserConversation.h"
#import "SKYReference.h"

@interface SKYContainer (Chat)


@end

@implementation SKYContainer (Chat)


- (void)loginWithFacebookAccessToken:(FBSDKAccessToken *)accessToken
                   completionHandler:(SKYContainerUserOperationActionCompletion)completionHandler
{
    SKYLoginUserOperation *operation =
        [SKYLoginUserOperation operationWithProvider:@"com.facebook"
                                  authenticationData:@{
                                      @"access_token" : accessToken.tokenString
                                  }];
    [self performUserAuthOperation:operation completionHandler:completionHandler];
}

- (NSString *)getUUID{
    NSString *UUID = [[NSUUID UUID] UUIDString];
    NSLog(@"UUID :%@",UUID);
    return UUID;
}


- (void)createConversationWithParticipantIds:(NSArray *)participantIds
                                withAdminIds:(NSArray *)adminIds withTitle:(NSString *)title
                           completionHandler:(SKYContainerConversationOperationActionCompletion)completionHandler{
    
    SKYConversation *conv = [SKYConversation recordWithRecordType:@"conversation"];
    conv.participantIds = participantIds;
    if(![adminIds containsObject:self.currentUserRecordID]){
        NSMutableArray *array = [adminIds mutableCopy];
        [array addObject:self.currentUserRecordID];
        adminIds = [array copy];
    }
    conv.adminIds = adminIds;
    conv.title = title;
    [self.publicCloudDatabase saveRecord:conv completion:^(SKYRecord *record, NSError *error) {
        if (error) {
            NSLog(@"error saving todo: %@", error);
        }
        NSLog(@"saved todo with recordID = %@", record.recordID);
        SKYConversation *con = [SKYConversation recordWithRecord:record];
        completionHandler(con, error);
    }];
 
}

- (void)getOrCreateDirectConversationWithuUserId:(NSString *)userId completionHandler:(SKYContainerConversationOperationActionCompletion)completionHandler{
    NSPredicate *pred1 = [NSPredicate predicateWithFormat:@"%@ in participant_ids",userId];
    NSPredicate *pred2 = [NSPredicate predicateWithFormat:@"%@ in participant_ids",self.currentUserRecordID];
    NSPredicate *pred3 = [NSPredicate predicateWithFormat:@"is_direct_message = %@",@YES];

    NSCompoundPredicate *predicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[pred1,pred2,pred3]];
    SKYQuery *query = [SKYQuery queryWithRecordType:@"conversation" predicate:predicate];
    query.limit = 1;
    
    [self.publicCloudDatabase performQuery:query completionHandler:^(NSArray *results, NSError *error) {
        if ([results count] >0) {
            SKYConversation *con = [SKYConversation recordWithRecord:[results objectAtIndex:0]];
            completionHandler(con ,error);
        }
        else{
            SKYConversation *conv = [SKYConversation recordWithRecordType:@"conversation"];
            conv.participantIds= @[userId,self.currentUserRecordID];
            conv.adminIds = @[userId,self.currentUserRecordID];
            conv.isDirectMessage = @YES;
            SKYDatabase *publicDB = [[SKYContainer defaultContainer] publicCloudDatabase];
            [publicDB saveRecord:conv completion:^(SKYRecord *record, NSError *error) {
                if (error) {
                    NSLog(@"error saving todo: %@", error);
                }
                NSLog(@"saved todo with recordID = %@", record.recordID);
                SKYConversation *con = [SKYConversation recordWithRecord:record];
                completionHandler(con, error);
            }];

        }
    }];
}

- (void)getConversationsCompletionHandler:(SKYContainerGetConversationListActionCompletion)completionHandler{
    NSPredicate *predicate =  [NSPredicate predicateWithFormat:@"user = %@",self.currentUserRecordID];
    SKYQuery *query = [SKYQuery queryWithRecordType:@"user_conversation" predicate:predicate];
    query.transientIncludes = @{ @"conversation" : [NSExpression expressionForKeyPath:@"conversation"] ,@"user" : [NSExpression expressionForKeyPath:@"user"] };
    [self.publicCloudDatabase performQuery:query completionHandler:^(NSArray *results, NSError *error) {
        NSMutableArray *resultArray = [[NSMutableArray alloc] init];
        for (SKYRecord *record in results) {
            NSLog(@"record :%@",[record transient]);
            //            SKYConversation *con = [SKYConversation recordWithRecord:record];
            SKYUserConversation *con = [SKYUserConversation recordWithRecord:record];
            [resultArray addObject:con];
        }
        completionHandler(resultArray,error);
    }];

}

- (void)getConversationWithConversationId:(NSString *)conversationId completionHandler:(SKYContainerConversationOperationActionCompletion)completionHandler{
    NSPredicate *pred1 =  [NSPredicate predicateWithFormat:@"user = %@",self.currentUserRecordID];
    NSPredicate *pred2 = [NSPredicate predicateWithFormat:@"conversation = %@", conversationId];
    NSCompoundPredicate *predicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[pred1,pred2]];
    SKYQuery *query = [SKYQuery queryWithRecordType:@"UserConversation" predicate:predicate];
    query.limit = 1;
    
    [self.publicCloudDatabase performQuery:query completionHandler:^(NSArray *results, NSError *error) {
        if ([results count] >0) {
            SKYUserConversation *con = [SKYUserConversation recordWithRecord:[results objectAtIndex:0]];
            completionHandler(con.conversation,error);
        }
        else{
            completionHandler(nil,error);
        }
    }];
}

- (void)deleteConversationWithConversationId:(NSString *)conversationId completionHandler:(SKYContainerConversationOperationActionCompletion)completionHandler{
    [self getConversationWithConversationId:conversationId completionHandler:^(SKYConversation *conversation, NSError *error) {
        if(!error){
            [self.publicCloudDatabase deleteRecordWithID:conversation.recordID completionHandler:^(SKYRecordID *recordID, NSError *error) {
                completionHandler(nil,error);
            }];
        }
        else{
            completionHandler(nil,error);
        }
    }];
}

- (void)updateConversationWithConversationId:(NSString *)conversationId withChange:(SKYConversationChange *)change completionHandler:(SKYContainerConversationOperationActionCompletion)completionHandler{
    [self getConversationWithConversationId:conversationId completionHandler:^(SKYConversation *conversation, NSError *error) {
        if(!error){
            if (change.title) {
                conversation.title = change.title;
                [self.publicCloudDatabase saveRecord:conversation completion:^(SKYRecord *record, NSError *error) {
                    SKYConversation *con = [SKYConversation recordWithRecord:record];
                    completionHandler(con,error);
                }];
            }
            else{
                completionHandler(conversation,error);
            }
        }
        else{
            completionHandler(nil,error);
        }
    }];
}

- (void)addParticipantsWithConversationId:(NSString *)conversationId withParticipantIds:(NSArray<NSString*> *)participantIds completionHandler:(SKYContainerConversationOperationActionCompletion)completionHandler{
    [self getConversationWithConversationId:conversationId completionHandler:^(SKYConversation *conversation, NSError *error) {
        if(!error){
            conversation.participantIds = [[conversation.participantIds arrayByAddingObjectsFromArray:participantIds] mutableCopy];
            [self.publicCloudDatabase saveRecord:conversation completion:^(SKYRecord *record, NSError *error) {
                SKYConversation *con = [SKYConversation recordWithRecord:record];
                completionHandler(con,error);
            }];
        }
        else{
            completionHandler(nil,error);
        }
    }];
}

- (void)removeParticipantsWithConversationId:(NSString *)conversationId withParticipantIds:(NSArray<NSString*> *)participantIds completionHandler:(SKYContainerConversationOperationActionCompletion)completionHandler{
    [self getConversationWithConversationId:conversationId completionHandler:^(SKYConversation *conversation, NSError *error) {
        if(!error){
            
            NSMutableArray *newParticipantArray = [conversation.participantIds mutableCopy];
            [newParticipantArray removeObjectsInArray:participantIds];
            conversation.participantIds = [newParticipantArray mutableCopy];
            [self.publicCloudDatabase saveRecord:conversation completion:^(SKYRecord *record, NSError *error) {
                SKYConversation *con = [SKYConversation recordWithRecord:record];
                completionHandler(con,error);
            }];
        }
        else{
            completionHandler(nil,error);
        }
    }];

}


- (void)addAdminsWithConversationId:(NSString *)conversationId withAdminIds:(NSMutableArray *)adminIds completionHandler:(SKYContainerConversationOperationActionCompletion)completionHandler{
    [self getConversationWithConversationId:conversationId completionHandler:^(SKYConversation *conversation, NSError *error) {
        if(!error){
            conversation.adminIds = [[conversation.adminIds arrayByAddingObjectsFromArray:adminIds] mutableCopy];
            [self.publicCloudDatabase saveRecord:conversation completion:^(SKYRecord *record, NSError *error) {
                SKYConversation *con = [SKYConversation recordWithRecord:record];
                completionHandler(con,error);
            }];
        }
        else{
            completionHandler(nil,error);
        }
    }];

}

- (void)removeAdminWithConversationId:(NSString *)conversationId withAdminIds:(NSMutableArray *)adminIds completionHandler:(SKYContainerConversationOperationActionCompletion)completionHandler{
    [self getConversationWithConversationId:conversationId completionHandler:^(SKYConversation *conversation, NSError *error) {
        if(!error){
            
            NSMutableArray *newParticipantArray = [conversation.adminIds mutableCopy];
            [newParticipantArray removeObjectsInArray:adminIds];
            conversation.adminIds = [newParticipantArray mutableCopy];
            [self.publicCloudDatabase saveRecord:conversation completion:^(SKYRecord *record, NSError *error) {
                SKYConversation *con = [SKYConversation recordWithRecord:record];
                completionHandler(con,error);
            }];
        }
        else{
            completionHandler(nil,error);
        }
    }];

}

- (void)createMessageWithConversationId:(NSString *)conversationId withBody:(NSString *)body withMetadata:(id)metadata completionHandler:(SKYContainerMessageOperationActionCompletion)completionHandler{
    SKYMessage *message = [[SKYMessage alloc] init];
    message.conversationId = [SKYReference referenceWithRecordID:[SKYRecordID recordIDWithRecordType:@"conversation" name:conversationId]];
    message.body = body;
    [self.publicCloudDatabase saveRecord:message completion:^(SKYRecord *record, NSError *error) {
        SKYMessage *msg = [SKYMessage recordWithRecord:record];
        completionHandler(msg, error);
    }];
}

- (NSString *)getAssetNameByType:(SKYChatMetaDataType) type{
    switch (type) {
        case SKYChatMetaDataImage:
            return SKYChatMetaDataAssetNameImage;
            break;
        case SKYChatMetaDataVoice:
            return SKYChatMetaDataAssetNameVoice;
            break;
    }
    return @"";
}

- (NSString *)getMimeTypeByType:(SKYChatMetaDataType) type{
    switch (type) {
        case SKYChatMetaDataImage:
            return @"image/png";
            break;
        case SKYChatMetaDataVoice:
            return @"audio/aac";
            break;
    }
    return @"";
}

- (NSString *)encodeToBase64String:(UIImage *)image {
    return @"SSBhbSBhIGJveS4=";
    NSString *baseString = [UIImagePNGRepresentation(image) base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
    NSLog(@"baseString :%@",baseString);
    return baseString;
}

- (void)removeMessageWithMessage:(SKYMessage *)msg{
//    [self delete]
    [self.publicCloudDatabase deleteRecordWithID:msg.recordID completionHandler:^(SKYRecordID *recordID, NSError *error) {
        if(error){
            NSLog(@"error removeMessageWithMessage: %@", error);
        }
        else{
            NSLog(@"success removeMessageWithMessage");
        }
    }];
}

- (void)createMessageWithConversationId:(NSString *)conversationId withBody:(NSString *)body withImages:(UIImage *)image withType:(SKYChatMetaDataType)type completionHandler:(SKYContainerMessageOperationActionCompletion)completionHandler{
    SKYMessage *message = [SKYMessage recordWithRecordType:@"message"];
    message.conversationId = [SKYReference referenceWithRecordID:[SKYRecordID recordIDWithRecordType:@"conversation" name:conversationId]];
    message.body = body;
    if (image && ((type == SKYChatMetaDataImage) || (type == SKYChatMetaDataVoice))) {
        NSString *assetName = [self getAssetNameByType:type];
        NSString* mimeType =[self getMimeTypeByType:type];
        if (assetName.length > 0 && mimeType.length > 0) {
            SKYAsset *asset = [SKYAsset assetWithName:assetName data:UIImageJPEGRepresentation(image,0.7)];
            asset.mimeType = mimeType;
            [self uploadAsset:asset completionHandler:^(SKYAsset *uploadedAsset, NSError *error) {
                if (error) {
                    NSLog(@"error uploading asset: %@", error);
                    [self.publicCloudDatabase saveRecord:message completion:^(SKYRecord *record, NSError *error) {
                        SKYMessage *msg = [SKYMessage recordWithRecord:record];
                        msg.isAlreadySyncToServer = true;
                        msg.isFail = false;
                        completionHandler(msg, error);
                    }];
                }
                else{
                    NSLog(@"createMessageWithConversationId uploadedAsset.name :%@",uploadedAsset.name);
                    message.attachment = uploadedAsset;
                    [self.publicCloudDatabase saveRecord:message completion:^(SKYRecord *record, NSError *error) {
                        SKYMessage *msg = [SKYMessage recordWithRecord:record];
//                        [self removeMessageWithMessage:msg];
                        msg.isAlreadySyncToServer = true;
                        msg.isFail = false;
                        completionHandler(msg, error);
                    }];
                }
            }];
        }
        else{
            [self.publicCloudDatabase saveRecord:message completion:^(SKYRecord *record, NSError *error) {
                SKYMessage *msg = [SKYMessage recordWithRecord:record];
                msg.isAlreadySyncToServer = true;
                msg.isFail = false;
                completionHandler(msg, error);
            }];
            
        }
        
        
    }
    else{
        [self.publicCloudDatabase saveRecord:message completion:^(SKYRecord *record, NSError *error) {
            SKYMessage *msg = [SKYMessage recordWithRecord:record];
            msg.isAlreadySyncToServer = true;
            msg.isFail = false;
            completionHandler(msg, error);
        }];
    }

}

- (void)createMessageWithConversationId:(NSString *)conversationId withBody:(NSString *)body withURL:(NSURL *)url withType:(SKYChatMetaDataType)type withDuration:(float)duration completionHandler:(SKYContainerMessageOperationActionCompletion)completionHandler{
    SKYMessage *message = [SKYMessage recordWithRecordType:@"message"];
    message.conversationId = [SKYReference referenceWithRecordID:[SKYRecordID recordIDWithRecordType:@"conversation" name:conversationId]];
    message.body = body;
    if (url && ((type == SKYChatMetaDataImage) || (type == SKYChatMetaDataVoice))) {
        NSString *assetName = [self getAssetNameByType:type];
        NSString* mimeType =[self getMimeTypeByType:type];
        if (assetName.length > 0 && mimeType.length > 0) {
            assetName = [NSString stringWithFormat:@"%@duration%.1fduration",assetName,duration];
            SKYAsset *asset = [SKYAsset assetWithName:assetName fileURL:url];
            asset.mimeType = mimeType;
            [self uploadAsset:asset completionHandler:^(SKYAsset *uploadedAsset, NSError *error) {
                if (error) {
                    NSLog(@"error uploading asset: %@", error);
                    [self.publicCloudDatabase saveRecord:message completion:^(SKYRecord *record, NSError *error) {
                        SKYMessage *msg = [SKYMessage recordWithRecord:record];
                        msg.isAlreadySyncToServer = true;
                        msg.isFail = false;
                        completionHandler(msg, error);
                    }];
                }
                else{
                    message.attachment = uploadedAsset;
                    [self.publicCloudDatabase saveRecord:message completion:^(SKYRecord *record, NSError *error) {
                        SKYMessage *msg = [SKYMessage recordWithRecord:record];
                        msg.isAlreadySyncToServer = true;
                        msg.isFail = false;
                        completionHandler(msg, error);
                    }];
                }
            }];
        }
        else{
            [self.publicCloudDatabase saveRecord:message completion:^(SKYRecord *record, NSError *error) {
                SKYMessage *msg = [SKYMessage recordWithRecord:record];
                msg.isAlreadySyncToServer = true;
                msg.isFail = false;
                completionHandler(msg, error);
            }];

        }
        

    }
    else{
        [self.publicCloudDatabase saveRecord:message completion:^(SKYRecord *record, NSError *error) {
            SKYMessage *msg = [SKYMessage recordWithRecord:record];
            msg.isAlreadySyncToServer = true;
            msg.isFail = false;
            completionHandler(msg, error);
        }];
    }
}


- (void)getOrCreateLastMessageReadithConversationId:(NSString *)conversationId completionHandler:(SKYContainerLastMessageReadOperationActionCompletion)completionHandler{
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"conversation_id = %@",conversationId];
    SKYQuery *query = [SKYQuery queryWithRecordType:@"last_message_read" predicate:pred];
    query.limit = 1;
    
    [self.privateCloudDatabase performQuery:query completionHandler:^(NSArray *results, NSError *error) {
        if ([results count] >0) {
            if (error) {
                completionHandler(nil ,error);

            }
            else{
                SKYLastMessageRead *msg = [SKYLastMessageRead recordWithRecord:[results objectAtIndex:0]];
                completionHandler(msg ,error);
            }
        }
        else{
            SKYLastMessageRead *lmr = [SKYLastMessageRead recordWithRecordType:@"last_message_read"];
            lmr.conversationId = conversationId;
            [self.publicCloudDatabase saveRecord:lmr completion:^(SKYRecord *record, NSError *error) {
                SKYLastMessageRead *msg = [SKYLastMessageRead recordWithRecord:record];
                completionHandler(msg ,error);
            }];
        }
    }];

}

- (void)markAsLastMessageReadWithConversationId:(NSString *)conversationId withMessageId:(NSString *)messageId completionHandler:(SKYContainerLastMessageReadOperationActionCompletion)completionHandler{
    [self getOrCreateLastMessageReadithConversationId:conversationId completionHandler:^(SKYLastMessageRead *lastMessageRead, NSError *error) {
        if (error) {
            completionHandler(lastMessageRead, error);
        }
        else{
            lastMessageRead.messageId = messageId;
            [self.publicCloudDatabase saveRecord:lastMessageRead completion:^(SKYRecord *record, NSError *error) {
                SKYLastMessageRead *msg = [SKYLastMessageRead recordWithRecord:record];
                completionHandler(msg,error);
            }];
        }
        
    }];
}

- (void)getTotalUnreadCount:(SKYContainerTotalUnreadCountOperationActionCompletion)completionHandler {
    [self callLambda:@"chat:total_unread" completionHandler:^(NSDictionary *response, NSError *error) {
        if (error) {
            NSLog(@"error calling chat:total_unread: %@", error);
        }
        
        NSLog(@"Received response = %@", response);
        completionHandler(response, error);
        
    }];
}

// FIXME: chat plugin don't have chat:get_unread_message_count lambda function, use this will only get error
- (void)getUnreadMessageCountWithConversationId:(NSString *)conversationId completionHandler:(SKYContainerUnreadCountOperationActionCompletion)completionHandler{
    [self callLambda:@"chat:get_unread_message_count" arguments:@[conversationId] completionHandler:^(NSDictionary *response, NSError *error) {
        if (error) {
            NSLog(@"error calling hello:someone: %@", error);
        }
        
        NSLog(@"Received response = %@", response);
        NSNumber *count = [response objectForKey:@"count"];
        if (count) {
            completionHandler([count integerValue], error);
        }
        else{
            completionHandler(0, error);
        }
        
    }];
}

- (void)getOrCreateUserChannelCompletionHandler:(SKYContainerChannelOperationActionCompletion)completionHandler{
    SKYQuery *query = [SKYQuery queryWithRecordType:@"user_channel" predicate:nil];
    [self.privateCloudDatabase performQuery:query completionHandler:^(NSArray *results, NSError *error) {
        if ([results count] > 0) {
            completionHandler([SKYUserChannel recordWithRecord:[results objectAtIndex:0]], error);
        }
        else{
            SKYUserChannel *userChannel = [SKYUserChannel recordWithRecordType:@"user_channel"];
            userChannel.name = [self getUUID];
            [self.privateCloudDatabase saveRecord:userChannel completion:^(SKYRecord *record, NSError *error) {
                SKYUserChannel *channel = [SKYUserChannel recordWithRecord:record];
                completionHandler(channel,error);
            }];
        }
    }];
}

- (void)subscribeHandler:(void (^)(NSDictionary *))messageHandler{
    [self getOrCreateUserChannelCompletionHandler:^(SKYUserChannel *userChannel, NSError *error) {
        if (!error) {
//            [self.pubsubClient connect];
//            [self.pubsubClient unsubscribe:userChannel.name];
            NSLog(@"subscribeHandler :%@",userChannel.name);
            [self.pubsubClient subscribeTo:userChannel.name handler:^(NSDictionary *data) {
                messageHandler(data);
            }];
//            SKYQuery *query = [[SKYQuery alloc] initWithRecordType:@"note" predicate:nil];
//            SKYSubscription *subscription = [[SKYSubscription alloc] initWithQuery:query subscriptionID:@"my notes"];
//            [[[SKYContainer defaultContainer] privateCloudDatabase] saveSubscription:subscription completionHandler:^(SKYSubscription *subscription, NSError *error) {
//               if (error) {
//                   NSLog(@"Failed to subscribe for my note: %@", error);
//                   return;
//               }
//               
//               NSLog(@"Subscription successful.");
//           }];
        }
    }];
}

- (void)getMessagesWithConversationId:(NSString *)conversationId withLimit:(NSString *)limit withBeforeTime:(NSDate *)beforeTime completionHandler:(SKYContainerGetMessagesActionCompletion)completionHandler{
    NSString *dateString = @"";
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
    [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSSSSZZZZZ"];
    dateString = [formatter stringFromDate:beforeTime];
    NSLog(@"dateString :%@",dateString);
    [self callLambda:@"chat:get_messages" arguments:@[conversationId,limit, dateString] completionHandler:^(NSDictionary *response, NSError *error) {
        if (error) {
            NSLog(@"error calling hello:someone: %@", error);
        }
        NSLog(@"Received response = %@", response);
        NSArray *resultArray = [response objectForKey:@"results"];
        if (resultArray.count > 0) {
            NSMutableArray *returnArray = [[NSMutableArray alloc] init];
            for(NSDictionary *obj in resultArray){
                SKYRecordID *recordID = [SKYRecordID recordIDWithCanonicalString:obj[SKYRecordSerializationRecordIDKey]];
                NSMutableDictionary *mutObj = [obj mutableCopy];
                [mutObj setObject:[@"message/" stringByAppendingString:[obj valueForKey:@"_id"]] forKey:@"_id"];
//                [mutObj setObject:[[obj valueForKey:@"_created_at"] stringByAppendingString:@"+00:00"] forKey:@"_created_at"];
                SKYRecordDeserializer *deserializer = [SKYRecordDeserializer deserializer];
                SKYRecord *record = [deserializer recordWithDictionary:mutObj];
                
                SKYMessage *msg = [SKYMessage recordWithRecord:record];
                msg.isAlreadySyncToServer = true;
                msg.isFail = false;
                if (msg){
                    [returnArray addObject:msg];
                }
            }
            returnArray = [[returnArray reverseObjectEnumerator] allObjects];
            completionHandler(returnArray,error);
        }
        else{
            completionHandler(nil, error);
        }
        
    }];

}

- (void)fetchAssetsByRecordId:(NSString *)recordId CompletionHandler:(SKYContainerGetAssetsActionCompletion)completionHandler{
    NSString *recordName = [@"" stringByAppendingString:recordId];
    NSLog(@"recordName :%@",recordName);
    [self.privateCloudDatabase fetchRecordWithID:[SKYRecordID recordIDWithCanonicalString:recordName] completionHandler:^(SKYRecord *record, NSError *error) {
        SKYAsset *asset = record[@"image"];
        completionHandler(asset, error);
    }];
}




@end
