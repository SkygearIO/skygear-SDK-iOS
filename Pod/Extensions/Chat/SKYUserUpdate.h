//
//  SKYUserUpdate.h
//  Pods
//
//  Created by Andrew Chung on 6/6/16.
//
//

#import "SKYChatRecord.h"
#import <SKYKit/SKYKit.h>

@interface SKYUserUpdate : SKYChatRecord
@property (strong, nonatomic) NSString *email;
@property (strong, nonatomic) NSString *username;

@end
