//
//  SKYLambdaOperation.h
//  SKYKit
//
//  Copyright 2015 Oursky Ltd.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

#import "SKYOperation.h"
#import <Foundation/Foundation.h>

/**
 <SKYLambdaOperation> is a subclass of <SKYOperation> that implements calling lambda functions
 registered in Ourd.
 */
@interface SKYLambdaOperation : SKYOperation

/**
 Instantiates an instance of <SKYLambdaOperation> with arguments specified as an array.
 */
- (instancetype)initWithAction:(NSString *)action arrayArguments:(NSArray *)arguments;

/**
 Instantiates an instance of <SKYLambdaOperation> with arguments specified as a dictionary.
 */
- (instancetype)initWithAction:(NSString *)action dictionaryArguments:(NSDictionary *)arguments;

/**
 Creates and returns an instance of <SKYLambdaOperation> with arguments specified as an array.
 */
+ (instancetype)operationWithAction:(NSString *)action arrayArguments:(NSArray *)arguments;

/**
 Creates and returns an instance of <SKYLambdaOperation> with arguments specified as a dictionary.
 */
+ (instancetype)operationWithAction:(NSString *)action
                dictionaryArguments:(NSDictionary *)arguments;

/**
 Sets or returns the action name of the labmda function.
 */
@property (nonatomic, copy) NSString *action;

/**
 Sets or returns the array arguments.

 If both arrayArguments and dictionaryArguments are set, only the object set to
 arrayArguments will be used.
 */
@property (nonatomic, copy) NSArray *arrayArguments;

/**
 Sets or returns the dictionary arguments.

 If both arrayArguments and dictionaryArguments are set, only the object set to
 arrayArguments will be used.
 */
@property (nonatomic, copy) NSDictionary *dictionaryArguments;

/**
 Sets or returns the block that is called when the operation completes.
 */
@property (nonatomic, copy) void (^lambdaCompletionBlock)
    (NSDictionary *result, NSError *operationError);

@end
