//
//  SKYDatabaseOperation.h
//  askq
//
//  Created by Kenji Pa on 21/1/15.
//  Copyright (c) 2015 Rocky Chan. All rights reserved.
//

#import "SKYOperation.h"

#import "SKYDatabase.h"

@interface SKYDatabaseOperation : SKYOperation

@property(strong, nonatomic) SKYDatabase *database;

@end
