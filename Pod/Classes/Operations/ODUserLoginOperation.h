//
//  ODUserLoginOperation.h
//  askq
//
//  Created by Patrick Cheung on 8/2/15.
//  Copyright (c) 2015 Rocky Chan. All rights reserved.
//

#import "ODOperation.h"
#import "ODUserRecordID.h"
#import "ODAccessToken.h"

@interface ODUserLoginOperation : ODOperation

@property (nonatomic, copy) NSString *email;
@property (nonatomic, copy) NSString *password;
@property (nonatomic, copy) void (^loginCompletionBlock)(ODUserRecordID *recordID, ODAccessToken *accessToken, NSError *error);

- (instancetype)initWithEmail:(NSString *)email password:(NSString *)password;

+ (instancetype)operationWithEmail:(NSString *)email password:(NSString *)password;

@end
