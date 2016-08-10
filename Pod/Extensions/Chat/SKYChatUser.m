//
//  SKYChatUser.m
//  Pods
//
//  Created by Andrew Chung on 6/7/16.
//
//

#import "SKYChatUser.h"

@implementation SKYChatUser
- (void)setUsername:(NSString *)username{
    self[@"username"] = username;
}

- (NSString *)username{
    return self[@"username"];
}

- (void)setEmail:(NSString *)email{
    self[@"email"] = email;
}

- (NSString *)email{
    return self[@"email"];
}

- (NSString *)toString{
    return  [NSString stringWithFormat:@"SKYChatUser :\nusername: %@\nemail: %@",self.username,self.email];
}


@end
