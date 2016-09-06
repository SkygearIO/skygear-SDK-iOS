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

- (void)setFirstName:(NSString *)firstName{
    self[@"first_name"] = firstName;
}

- (NSString *)firstName{
    return self[@"first_name"];

}

- (void)setLastName:(NSString *)lastName{
    self[@"last_name"] = lastName;

}

- (NSString *)lastName{
    return self[@"last_name"];

}

- (void)setDisplayName:(NSString *)displayName{
    self[@"display_name"] = displayName;

}

- (NSString *)displayName{
    return self[@"display_name"];

}

- (NSString *)toString{
    return  [NSString stringWithFormat:@"SKYChatUser :\nusername: %@\nemail: %@",self.username,self.email];
}


@end
