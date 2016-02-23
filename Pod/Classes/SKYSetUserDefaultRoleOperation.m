//
//  SKYSetUserDefaultRoleOperation.m
//  Pods
//
//  Created by Ben Lei on 22/2/2016.
//
//

#import "SKYSetUserDefaultRoleOperation.h"

@implementation SKYSetUserDefaultRoleOperation

+ (instancetype)operationWithRoles:(NSArray<SKYRole *> *)roles
{
    return [[SKYSetUserDefaultRoleOperation alloc] initWithRoles:roles];
}

- (instancetype)initWithRoles:(NSArray <SKYRole *> *)roles
{
    self = [super init];
    if (self) {
        _roles = roles;
    }

    return self;
}

// override
- (void)prepareForRequest
{
    if ([self.roles count] == 0) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException
                                       reason:@"Roles should not be nil or empty."
                                     userInfo:nil];
    }

    NSMutableArray<NSString *> *roleNames = [[NSMutableArray alloc] initWithCapacity:self.roles.count];
    [self.roles enumerateObjectsUsingBlock:^(SKYRole *obj, NSUInteger idx, BOOL *stop) {
        [roleNames addObject:obj.name];
    }];

    self.request = [[SKYRequest alloc] initWithAction:@"role:default"
                                              payload:@{ @"roles": roleNames }];
    self.request.accessToken = self.container.currentAccessToken;
}

// override
- (void)operationWillStart
{
    [super operationWillStart];
    if (!self.container.currentAccessToken) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException
                                       reason:@"SKYContainer has no currently logged-in user"
                                     userInfo:nil];
    }
}

// override
- (void)handleRequestError:(NSError *)error
{
    if (self.setUserDefaultRoleCompletionBlock) {
        self.setUserDefaultRoleCompletionBlock(nil, error);
    }
}

// override
- (void)handleResponse:(SKYResponse *)aResponse
{
    NSDictionary *response = aResponse.responseDictionary[@"result"];
    NSArray<NSString *> *roleNames = [response objectForKey:@"roles"];

    NSMutableArray<SKYRole *> *roles = [[NSMutableArray alloc] initWithCapacity:roleNames.count];
    [roleNames enumerateObjectsUsingBlock:^(NSString *perRoleName, NSUInteger idx, BOOL *stop) {
        [roles addObject:[SKYRole roleWithName:perRoleName]];
    }];

    if (self.setUserDefaultRoleCompletionBlock) {
        self.setUserDefaultRoleCompletionBlock(roles, nil);
    }
}

@end
