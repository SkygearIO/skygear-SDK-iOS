//
//  SKYUserChannel.h
//  Pods
//
//  Created by Andrew Chung on 6/2/16.
//
//

#import <SKYKit/SKYKit.h>
#import "SKYChatRecord.h"

@interface SKYUserChannel : SKYChatRecord
@property (strong, nonatomic) NSString* name;

- (id)init;

@end
