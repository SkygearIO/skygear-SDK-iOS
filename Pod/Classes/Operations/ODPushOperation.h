//
//  ODPushOperation.h
//  askq
//
//  Created by Kenji Pa on 26/1/15.
//  Copyright (c) 2015 Rocky Chan. All rights reserved.
//

#import "ODOperation.h"

#import "ODNotificationInfo.h"
#import "ODUserRecordID.h"

@interface ODPushOperation : ODOperation

- (instancetype)initWithUserRecordIDs:(NSArray /* ODUserRecordID */ *)userRecordIDs alertBody:(NSString *)alertBody;
- (instancetype)initWithUserRecordIDs:(NSArray /* ODUserRecordID */ *)userRecordIDs alertBody:(NSString *)alertBody alertActionLocalizationKey:(NSString *)alertActionLocalizationKey;
- (instancetype)initWithUserRecordIDs:(NSArray /* ODUserRecordID */ *)userRecordIDs alertBody:(NSString *)alertBody alertActionLocalizationKey:(NSString *)alertActionLocalizationKey soundName:(NSString *)soundName;

- (instancetype)initWithUserRecordIDs:(NSArray /* ODUserRecordID */ *)userRecordIDs alertLocalizationKey:(NSString *)alertLocalizationKey alertLocalizationArgs:(NSArray *)alertLocalizationArgs;
- (instancetype)initWithUserRecordIDs:(NSArray /* ODUserRecordID */ *)userRecordIDs alertLocalizationKey:(NSString *)alertLocalizationKey alertLocalizationArgs:(NSArray *)alertLocalizationArgs alertActionLocalizationKey:(NSString *)alertActionLocalizationKey;
- (instancetype)initWithUserRecordIDs:(NSArray /* ODUserRecordID */ *)userRecordIDs alertLocalizationKey:(NSString *)alertLocalizationKey alertLocalizationArgs:(NSArray *)alertLocalizationArgs alertActionLocalizationKey:(NSString *)alertActionLocalizationKey soundName:(NSString *)soundName;

- (instancetype)initWithUserRecordID:(ODUserRecordID *)userRecordID notificationInfo:(ODNotificationInfo *)notificationInfo;
- (instancetype)initWithUserRecordIDs:(NSArray /* ODUserRecordID */ *)userRecordIDs notificationInfo:(ODNotificationInfo *)notificationInfo NS_DESIGNATED_INITIALIZER;

+ (instancetype)operationWithUserRecordIDs:(NSArray /* ODUserRecordID */ *)userRecordIDs alertBody:(NSString *)alertBody;
+ (instancetype)operationWithUserRecordIDs:(NSArray /* ODUserRecordID */ *)userRecordIDs alertBody:(NSString *)alertBody alertActionLocalizationKey:(NSString *)alertActionLocalizationKey;
+ (instancetype)operationWithUserRecordIDs:(NSArray /* ODUserRecordID */ *)userRecordIDs alertBody:(NSString *)alertBody alertActionLocalizationKey:(NSString *)alertActionLocalizationKey soundName:(NSString *)soundName;

+ (instancetype)operationWithUserRecordIDs:(NSArray /* ODUserRecordID */ *)userRecordIDs alertLocalizationKey:(NSString *)alertLocalizationKey alertLocalizationArgs:(NSArray *)alertLocalizationArgs;
+ (instancetype)operationWithUserRecordIDs:(NSArray /* ODUserRecordID */ *)userRecordIDs alertLocalizationKey:(NSString *)alertLocalizationKey alertLocalizationArgs:(NSArray *)alertLocalizationArgs alertActionLocalizationKey:(NSString *)alertActionLocalizationKey;
+ (instancetype)operationWithUserRecordIDs:(NSArray /* ODUserRecordID */ *)userRecordIDs alertLocalizationKey:(NSString *)alertLocalizationKey alertLocalizationArgs:(NSArray *)alertLocalizationArgs alertActionLocalizationKey:(NSString *)alertActionLocalizationKey soundName:(NSString *)soundName;

+ (instancetype)operationWithUserRecordID:(ODUserRecordID *)userRecordID notificationInfo:(ODNotificationInfo *)notificationInfo;
+ (instancetype)operationWithUserRecordIDs:(NSArray /* ODUserRecordID */ *)userRecordIDs notificationInfo:(ODNotificationInfo *)notificationInfo;

@property (nonatomic, copy) NSArray *userRecordIDs;

/**
 The configuration of notifications sent by this operation.

 ## Discussion

 For an opertion object not created by the family of `init` methods that receive a `ODNotificationInfo` object, the notificationInfo object created will have the shouldBadge property equalled YES by default.

 If configuration of properties `alertLaunchImage`, `shouldBadge` or `shouldSendContentAvailable` is desired, create and set a new `ODNotificationInfo` object manually or use the `-[ODPushOperation initWithUserRecordIDs:notificationInfo:]` initializer. The value of property `desiredKeys` configured on such notificationInfo will be ignored.
 
 If this property is nil when the operation starts, an NSInternalInconsistencyException will be thrown.
 */
@property (nonatomic, copy) ODNotificationInfo *notificationInfo;

@property (nonatomic, copy) void(^perUserRecordIDCompletionBlock)(ODUserRecordID* userRecordID, NSError *error);
@property (nonatomic, copy) void(^pushCompletionBlock)(NSError *error);

@end
