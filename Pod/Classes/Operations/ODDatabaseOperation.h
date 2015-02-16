//
//  ODDatabaseOperation.h
//  askq
//
//  Created by Kenji Pa on 21/1/15.
//  Copyright (c) 2015 Rocky Chan. All rights reserved.
//

#import "ODOperation.h"

#import "ODDatabase.h"

@interface ODDatabaseOperation : ODOperation

@property(strong, nonatomic) ODDatabase *database;

@end
