//
//  Message.h
//  Pods
//
//  Created by Andrew Chung on 6/2/16.
//
//

#import <SKYKit/SKYKit.h>
#import "SKYChatRecord.h"

@class SKYMetadata,SKYReference;

@interface SKYMessage : SKYChatRecord

@property (strong, nonatomic)SKYReference* conversationId;
@property (strong, nonatomic)NSString* conversationID;
@property (strong, nonatomic)NSString* body;
@property (strong, nonatomic)NSDictionary* metadata;
@property (strong, nonatomic)NSDate* createdAt;
@property (strong, nonatomic)SKYAsset* attachment;

@property (strong, nonatomic)UIImage* attachmentImage;
@property (assign, nonatomic)bool isSyncingToServer;
@property (assign, nonatomic)bool isAlreadySyncToServer;
@property (assign, nonatomic)bool isFail;

- (id)init;
- (NSInteger)getMsgType;
- (NSString *)getAssetURLForImage;
- (NSString *)getAssetURLForVoice;
- (float)getVoiceDuration;
@end
