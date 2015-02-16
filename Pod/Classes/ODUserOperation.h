//
//  ODUserOperation.h
//  askq
//
//  Created by Kenji Pa on 16/1/15.
//  Copyright (c) 2015 Rocky Chan. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ODOperation.h"
#import "ODRecordID.h"
#import "ODUserRecordID.h"

typedef enum : NSInteger {
    ODUserOperationSignup = 0,
    ODUserOperationLogin = 1,
    ODUserOperationLogout = 2,
} ODUserOperationAction;

typedef void(^ODUserOperationActionCompletion)(ODUserRecordID *user, NSError *error);

@interface ODUserOperation : ODOperation

- (instancetype)initToSignupWithUsername:(NSString *)username password:(NSString *)password;
- (instancetype)initToLoginWithUsername:(NSString *)username password:(NSString *)password;
- (instancetype)initToLogout;

@property (strong, nonatomic) ODUserRecordID *userRecordID;
@property (strong, nonatomic) NSString *username;
@property (strong, nonatomic) NSString *password;   // write only
- (NSString *)password UNAVAILABLE_ATTRIBUTE;
@property (nonatomic) ODUserOperationAction action;
@property (nonatomic, copy) ODUserOperationActionCompletion actionCompletionBlock;

@end
