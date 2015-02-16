//
//  ODContainer+ODPush.h
//  askq
//
//  Created by Kenji Pa on 26/1/15.
//  Copyright (c) 2015 Rocky Chan. All rights reserved.
//

#import "ODContainer.h"

#import "ODUserRecordID.h"

@interface ODContainer (ODPush)

- (void)pushToUserRecordID:(ODUserRecordID *)userRecordID message:(NSString *)message;
- (void)pushToUserRecordIDs:(NSArray *)userRecordIDs message:(NSString *)message;

@end
