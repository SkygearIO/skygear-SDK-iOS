//
//  ODLambdaOperation.h
//  Pods
//
//  Created by atwork on 3/7/15.
//
//

#import <Foundation/Foundation.h>
#import "ODOperation.h"

/**
 <ODLambdaOperation> is a subclass of <ODOperation> that implements calling lambda functions registered in Ourd.
 */
@interface ODLambdaOperation : ODOperation

/**
 Instantiates an instance of <ODLambdaOperation> with arguments specified as an array.
 */
- (instancetype)initWithAction:(NSString *)action arrayArguments:(NSArray *)arguments;

/**
 Instantiates an instance of <ODLambdaOperation> with arguments specified as a dictionary.
 */
- (instancetype)initWithAction:(NSString *)action dictionaryArguments:(NSDictionary *)arguments;

/**
 Sets or returns the action name of the labmda function.
 */
@property(nonatomic, copy) NSString *action;

/**
 Sets or returns the array arguments.
 
 If both arrayArguments and dictionaryArguments are set, only the object set to
 arrayArguments will be used.
 */
@property(nonatomic, copy) NSArray *arrayArguments;

/**
 Sets or returns the dictionary arguments.
 
 If both arrayArguments and dictionaryArguments are set, only the object set to
 arrayArguments will be used.
 */
@property(nonatomic, copy) NSDictionary *dictionaryArguments;

/**
 Sets or returns the block that is called when the operation completes.
 */
@property(nonatomic, copy) void (^lambdaCompletionBlock)(NSDictionary *result, NSError *operationError);

@end
