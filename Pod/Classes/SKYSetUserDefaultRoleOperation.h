//
//  SKYSetUserDefaultRoleOperation.h
//  Pods
//
//  Created by Ben Lei on 22/2/2016.
//
//

#import <SKYKit/SKYKit.h>

@interface SKYSetUserDefaultRoleOperation : SKYOperation

@property (nonatomic, readonly, strong) NSArray <SKYRole *> *roles;
@property (nonatomic, copy) void (^setUserDefaultRoleCompletionBlock)
    (NSArray<SKYRole *> *roles, NSError *error);

+ (instancetype)operationWithRoles:(NSArray <SKYRole *> *)roles;

@end
