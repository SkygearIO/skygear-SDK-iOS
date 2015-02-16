//
//  ODPushOperation.h
//  askq
//
//  Created by Kenji Pa on 26/1/15.
//  Copyright (c) 2015 Rocky Chan. All rights reserved.
//

#import "ODOperation.h"

#import "ODUserRecordID.h"

@interface ODPushOperation : ODOperation

- initWithUserRecordID:(ODUserRecordID *)userRecordID message:(NSString *)message;
- initWithUserRecordIDs:(NSArray *)userRecordIDs message:(NSString *)message;

@property (nonatomic, copy) NSArray *userRecordIDs;
@property (nonatomic, copy) NSString *message;

@property (nonatomic, copy) void(^perUserRecordIDCompletionBlock)(ODUserRecordID* userRecordID, NSError *error);
@property (nonatomic, copy) void(^pushCompletionBlock)(NSError *error);

@end
