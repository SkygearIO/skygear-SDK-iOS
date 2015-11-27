//
//  SKYLoginUserOperation.m
//  askq
//
//  Created by Patrick Cheung on 8/2/15.
//  Copyright (c) 2015 Rocky Chan. All rights reserved.
//

#import "SKYLoginUserOperation.h"
#import "SKYOperation_Private.h"
#import "SKYRequest.h"
#import "SKYUserRecordID_Private.h"

@implementation SKYLoginUserOperation

- (instancetype)initWithEmail:(NSString *)email
                     username:(NSString *)username
                     password:(NSString *)password
{
    if ((self = [super init])) {
        self.username = username;
        self.email = email;
        self.password = password;
    }
    return self;
}

+ (instancetype)operationWithUsername:(NSString *)username password:(NSString *)password
{
    return [[self alloc] initWithEmail:nil username:username password:password];
}

+ (instancetype)operationWithEmail:(NSString *)email password:(NSString *)password
{
    return [[self alloc] initWithEmail:email username:nil password:password];
}

- (void)prepareForRequest
{
    NSMutableDictionary *payload = [[NSMutableDictionary alloc] init];
    if (self.username) {
        payload[@"username"] = self.username;
    }
    if (self.email) {
        payload[@"email"] = self.email;
    }
    payload[@"password"] = self.password;
    self.request = [[SKYRequest alloc] initWithAction:@"auth:login" payload:payload];
    self.request.APIKey = self.container.APIKey;
}

- (void)operationWillStart
{
    [super operationWillStart];
    if (!self.container.APIKey) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException
                                       reason:@"SKYContainer is not configured with an API key."
                                     userInfo:nil];
    }
}

- (void)setLoginCompletionBlock:(void (^)(SKYUserRecordID *, SKYAccessToken *,
                                          NSError *))loginCompletionBlock
{
    if (loginCompletionBlock) {
        __weak typeof(self) weakSelf = self;
        self.completionBlock = ^{
            SKYUserRecordID *recordID = nil;
            SKYAccessToken *accessToken = nil;
            NSError *error = nil;
            if (!weakSelf.error) {
                NSDictionary *response = weakSelf.response[@"result"];
                if (response[@"user_id"] && response[@"access_token"]) {
                    recordID = [SKYUserRecordID recordIDWithUsername:response[@"user_id"]];
                    accessToken =
                        [[SKYAccessToken alloc] initWithTokenString:response[@"access_token"]];
                } else {
                    error = [NSError errorWithDomain:(NSString *)SKYOperationErrorDomain
                                                code:0
                                            userInfo:@{
                                                NSLocalizedDescriptionKey :
                                                    @"Returned data does not contain expected data."
                                            }];
                }
            } else {
                error = weakSelf.error;
            }

            if (!error) {
                NSLog(@"User logged in with UserRecordID %@.", recordID.recordName);
            }
            loginCompletionBlock(recordID, accessToken, error);
        };
    } else {
        self.completionBlock = nil;
    }
}

@end
