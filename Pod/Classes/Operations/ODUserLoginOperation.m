//
//  ODUserLoginOperation.m
//  askq
//
//  Created by Patrick Cheung on 8/2/15.
//  Copyright (c) 2015 Rocky Chan. All rights reserved.
//

#import "ODUserLoginOperation.h"
#import "ODRequest.h"
#import "ODUserRecordID_Private.h"


@implementation ODUserLoginOperation

- (instancetype)initWithEmail:(NSString *)email password:(NSString *)password
{
    if ((self = [super init])) {
        self.email = email;
        self.password = password;
    }
    return self;
}

- (void)prepareForRequest
{
    self.request = [[ODRequest alloc] initWithAction:@"auth:login"
                                             payload:@{
                                                       @"user_id": self.email,
                                                       @"password": self.password,
                                                       }];
    self.request.APIKey = self.container.APIKey;
}

- (void)operationWillStart
{
    [super operationWillStart];
    if (!self.container.APIKey) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException
                                       reason:@"ODContainer is not configured with an API key."
                                     userInfo:nil];
    }
}

- (void)setLoginCompletionBlock:(void (^)(ODUserRecordID *, ODAccessToken *, NSError *))loginCompletionBlock
{
    if (loginCompletionBlock) {
        __weak typeof(self) weakSelf = self;
        self.completionBlock = ^{
            ODUserRecordID *recordID = nil;
            ODAccessToken *accessToken = nil;
            NSError *error = nil;
            if (!weakSelf.error) {
                NSDictionary *response = weakSelf.response[@"result"];
                if (response[@"user_id"] && response[@"access_token"]) {
                    recordID = [ODUserRecordID recordIDWithUsername:response[@"user_id"]];
                    accessToken = [[ODAccessToken alloc] initWithTokenString:response[@"access_token"]];
                } else {
                    error = [NSError errorWithDomain:(NSString *)ODOperationErrorDomain
                                                code:0
                                            userInfo:@{
                                                       NSLocalizedDescriptionKey: @"Returned data does not contain expected data."
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
