//
//  SKYUserUpdate.h
//  Pods
//
//  Created by Andrew Chung on 6/6/16.
//
//

#import <SKYKit/SKYKit.h>
#import "SKYChatRecord.h"

@interface SKYUserUpdate : SKYChatRecord
@property (strong, nonatomic) NSString* email;
@property (strong, nonatomic) NSString* username;

@end
