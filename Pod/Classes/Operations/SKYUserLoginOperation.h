//
//  SKYUserLoginOperation.h
//  askq
//
//  Created by Patrick Cheung on 8/2/15.
//  Copyright (c) 2015 Rocky Chan. All rights reserved.
//

#import "SKYOperation.h"
#import "SKYUserRecordID.h"
#import "SKYAccessToken.h"

@interface SKYUserLoginOperation : SKYOperation

@property (nonatomic, copy) NSString *username;
@property (nonatomic, copy) NSString *email;
@property (nonatomic, copy) NSString *password;
@property (nonatomic, copy) void (^loginCompletionBlock)
    (SKYUserRecordID *recordID, SKYAccessToken *accessToken, NSError *error);

+ (instancetype)operationWithUsername:(NSString *)username password:(NSString *)password;
+ (instancetype)operationWithEmail:(NSString *)email password:(NSString *)password;

@end
