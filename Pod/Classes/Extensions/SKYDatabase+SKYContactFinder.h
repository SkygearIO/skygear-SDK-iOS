//
//  SKYDatabase+SKYContactFinder.h
//  askq
//
//  Created by Kenji Pa on 26/1/15.
//  Copyright (c) 2015 Rocky Chan. All rights reserved.
//

#import "SKYDatabase.h"

@interface SKYDatabase (SKYContactFinder)

- (void)findUserByLocalAddressBookWithCompletionHandler:(void(^)(NSArray /* SKYRecord */ *users, NSError *error))completionHandler;

@end
