//
//  SKYChatUser.h
//  Pods
//
//  Created by Andrew Chung on 6/7/16.
//
//

#import <SKYKit/SKYKit.h>
#import "SKYChatRecord.h"

@interface SKYChatUser : SKYChatRecord

@property (strong, nonatomic) NSString* username;
@property (strong, nonatomic) NSString* email;

- (NSString *)toString;

@end
