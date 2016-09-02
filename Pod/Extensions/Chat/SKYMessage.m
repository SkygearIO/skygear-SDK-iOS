//
//  Message.m
//  Pods
//
//  Created by Andrew Chung on 6/2/16.
//
//

#import "SKYMessage.h"
#import "SKYRecord.h"

@implementation SKYMessage

- (id)init{
    return [SKYRecord recordWithRecordType:@"message"];
}

- (void)setConversationId:(SKYReference *)conversationId{
    self[@"conversation_id"] = conversationId;
}

- (SKYReference *)conversationId{
    return self[@"conversation_id"];
}

- (NSString *)conversationID{
    return self.conversationId.recordID.recordName;
}

- (void)setBody:(NSString *)body{
    self[@"body"] = body;
}

- (NSString *)body{
    return self[@"body"];
}

- (void)setMetadata:(NSDictionary *)metadata{
    self[@"metadata"] = metadata;
}

- (NSDictionary *)metadata{
    return self[@"metadata"];
}

- (NSDate *)createdAt{
    return self.creationDate;
}

- (SKYAsset *)attachment{
    return self[@"attachment"];
}

- (void)setAttachment:(SKYAsset *)attachment{
    self[@"attachment"] = attachment;
}

- (NSInteger)getMsgType{
    if(!self.attachment) {
        return 2;
    }
    NSString *name = self.attachment.name;
    NSLog(@"getMsgType name:%@",name);
    if(!name || name.length <1 ){
        return 2;
    }
    if ([name containsString:@"message-image"] ){
        return 0;
    }
    else if([name containsString:@"message-voice"] ) {
        return 1;
    }
    return 2;
}

- (NSString *)getAssetURLForImage{
    if(!self.attachment) {
        return @"";
    }
    if (![self.attachment.name containsString:@"message-image"] ){
        return @"";
    }
    NSString *metaDataString = self.attachment.url.absoluteString;
    return metaDataString;
}

- (NSString *)getAssetURLForVoice{
    if(!self.attachment) {
        return @"";
    }
    if (![self.attachment.name containsString:@"message-voice"] ){
        return @"";
    }
    NSString *metaDataString = self.attachment.url.absoluteString;
    NSLog(@"getAssetURLForVoice :%@",metaDataString);
    return metaDataString;
//    NSString *recordID = @"";
//    NSString *metaDataString = [self.metadata valueForKey:@"message-voice"];
//    NSArray *splitString = [metaDataString componentsSeparatedByString:@"-message-voice"];
//    if (splitString.count > 0) {
//        recordID = [splitString objectAtIndex:0];
//    }
//    return recordID;
}

- (float)getVoiceDuration{
    if(!self.attachment) {
        return 0.0;
    }
    if (![self.attachment.name containsString:@"message-voice"] ){
        return 0.0;
    }
    NSArray *splitArray = [self.attachment.name componentsSeparatedByString:@"duration"];
    if(splitArray.count > 1){
        NSString *time = [splitArray objectAtIndex:1];
        return time.floatValue;
    }
    return 0.0;
}

@end
