//
//  ODDatabase+ODContactFinder.h
//  askq
//
//  Created by Kenji Pa on 26/1/15.
//  Copyright (c) 2015 Rocky Chan. All rights reserved.
//

#import "ODDatabase.h"

@interface ODDatabase (ODContactFinder)

- (void)findUserByLocalAddressBookWithCompletionHandler:(void(^)(NSArray /* ODRecord */ *users, NSError *error))completionHandler;

@end
