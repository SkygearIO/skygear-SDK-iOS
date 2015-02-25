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
    self.request = [[ODRequest alloc] initWithAction:self.createNewUser ? @"auth:signup" : @"auth:login"
                                             payload:@{
                                                       @"email": self.email,
                                                       @"password": self.password,
                                                       }];
}

- (void)setLoginCompletionBlock:(void (^)(ODUserRecordID *, ODAccessToken *, NSError *))loginCompletionBlock
{
    if (loginCompletionBlock) {
        __weak typeof(self) weakSelf = self;
        self.completionBlock = ^{
            if (!weakSelf.error) {
                NSDictionary *response = weakSelf.response;
                ODUserRecordID *recordID = [[ODUserRecordID alloc] initWithRecordName:response[@"user_id"]];
                ODAccessToken *accessToken = [[ODAccessToken alloc] initWithTokenString:response[@"access_token"]];
                NSLog(@"User logged in with UserRecordID %@ and AccessToken %@", response[@"user_id"], response[@"access_token"]);
                loginCompletionBlock(recordID, accessToken, nil);
            } else {
                loginCompletionBlock(nil, nil, weakSelf.error);
            }
        };
    } else {
        self.completionBlock = nil;
    }
}


@end
