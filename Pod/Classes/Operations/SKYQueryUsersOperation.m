//
//  SKYDiscoverUserOperation.m
//  Pods
//
//  Created by Kenji Pa on 29/5/15.
//
//

#import "SKYQueryUsersOperation.h"

#import "SKYError.h"
#import "SKYUser.h"
#import "SKYUserDeserializer.h"

NSString *NSStringFromRelationDirection(SKYRelationDirection direction)
{
    switch (direction) {
        case SKYRelationDirectionOutward:
            return @"outward";
            break;
        case SKYRelationDirectionInward:
            return @"inward";
            break;
        case SKYRelationDirectionMutual:
            return @"mutual";
            break;
        default:
            @throw([NSException exceptionWithName:NSInternalInconsistencyException
                                           reason:@"Unrecgonized relation direction"
                                         userInfo:@{
                                             @"relationDirection" : @(direction)
                                         }]);
    }
}

@interface SKYQueryUsersOperation ()

@property (strong, nonatomic) SKYUserDeserializer *deserializer;
@property (nonatomic, readwrite, assign) SKYUserDiscoveryMethod discoveryMethod;

@end

@implementation SKYQueryUsersOperation

+ (instancetype)discoverUsersOperationByEmails:(NSArray *)emails
{
    return [[self alloc] initWithEmails:emails];
}

+ (instancetype)queryUsersOperationByRelation:(SKYRelation *)relation
{
    return [[self alloc] initWithRelation:relation];
}

+ (instancetype)queryUsersOperationByRelation:(SKYRelation *)relation
                                    direction:(SKYRelationDirection)direction
{
    return [[self alloc] initWithRelation:relation direction:direction];
}

- (instancetype)initWithEmails:(NSArray *)emails
{
    self = [super init];
    if (self) {
        self.deserializer = [SKYUserDeserializer deserializer];
        self.discoveryMethod = SKYUserDiscoveryMethodEmail;
        self.emails = emails;
    }
    return self;
}

- (instancetype)initWithRelation:(SKYRelation *)relation
{
    return [self initWithRelation:relation direction:SKYRelationDirectionOutward];
}

- (instancetype)initWithRelation:(SKYRelation *)relation direction:(SKYRelationDirection)direction
{
    self = [super init];
    if (self) {
        self.deserializer = [SKYUserDeserializer deserializer];
        self.discoveryMethod = SKYUserDiscoveryMethodRelation;
        self.relation = relation;
        self.relationDirection = direction;
    }
    return self;
}

- (void)prepareForRequest
{
    NSString *directionString;

    switch (self.discoveryMethod) {
        case SKYUserDiscoveryMethodEmail:
            self.request = [[SKYRequest alloc] initWithAction:@"user:query"
                                                      payload:@{
                                                          @"emails" : self.emails
                                                      }];
            break;
        case SKYUserDiscoveryMethodRelation:
            directionString = NSStringFromRelationDirection(self.relationDirection);
            self.request = [[SKYRequest alloc] initWithAction:@"relation:query"
                                                      payload:@{
                                                          @"name" : self.relation.name,
                                                          @"direction" : directionString,
                                                      }];
            break;
        default:
            @throw([NSException exceptionWithName:NSInternalInconsistencyException
                                           reason:@"Unrecgonized user discovery method"
                                         userInfo:@{
                                             @"discoveryMethod" : @(self.discoveryMethod)
                                         }]);
    }

    self.request.accessToken = self.container.currentAccessToken;
}

- (void)handleRequestError:(NSError *)error
{
    if (self.queryUserCompletionBlock) {
        self.queryUserCompletionBlock(nil, error);
    }
}

- (void)processResultInfo:(NSDictionary *)resultInfo
{
    if (![resultInfo isKindOfClass:[NSDictionary class]]) {
        return;
    }

    [self willChangeValueForKey:@"overallCount"];
    _overallCount = [resultInfo[@"count"] unsignedIntegerValue];
    [self didChangeValueForKey:@"overallCount"];
}

- (void)handleResponse:(SKYResponse *)responseObject
{
    NSDictionary *response = responseObject.responseDictionary;
    [self processResultInfo:response[@"info"]];
    NSArray *result = response[@"result"];
    NSArray *userDicts = [self.class itemDictsFromResult:result];
    NSMutableArray *users = [NSMutableArray arrayWithCapacity:userDicts.count];

    for (NSDictionary *userDict in userDicts) {
        SKYUser *user = [self.deserializer userWithDictionary:userDict];
        if (!user) {
            NSLog(@"Malformed user: %@", userDict);
            continue;
        }

        [users addObject:user];
    }

    NSError *error = nil;

    if (self.discoveryMethod == SKYUserDiscoveryMethodEmail) {
        NSDictionary *usersByEmail = [self.class usersByEmail:users];

        NSMutableArray *emailsNotFound = [NSMutableArray array];
        for (NSString *email in self.emails) {
            if (usersByEmail[email] == nil) {
                [emailsNotFound addObject:email];
            }
        }

        if (emailsNotFound.count) {
            NSDictionary *userInfo = @{SKYPartialEmailsNotFoundKey : emailsNotFound};
            error = [NSError errorWithDomain:SKYOperationErrorDomain
                                        code:SKYErrorPartialFailure
                                    userInfo:userInfo];
        }
    }

    if (self.perUserCompletionBlock) {
        for (SKYUser *user in users) {
            self.perUserCompletionBlock(user);
        }
    }

    if (self.queryUserCompletionBlock) {
        self.queryUserCompletionBlock(users, error);
    }
}

// NOTE(limouren): a very strong candidate to be refactored as utility method
+ (NSArray *)itemDictsFromResult:(NSArray *)result
{
    NSMutableArray *itemDicts = [NSMutableArray arrayWithCapacity:result.count];

    for (NSDictionary *item in result) {
        NSString *itemID = item[@"id"];
        NSString *itemType = item[@"type"];
        if (!itemID.length) {
            NSLog(@"Found item with empty ID: %@", item);
            continue;
        }

        if (![itemType isEqualToString:@"user"]) {
            NSLog(@"Found item with unrecgonized item type = %@", itemType);
            continue;
        }

        NSDictionary *itemData = item[@"data"];
        if (!itemData.count) {
            NSLog(@"Found item with empty data: %@", item);
        }

        [itemDicts addObject:itemData];
    }

    return itemDicts;
}

+ (NSDictionary *)usersByEmail:(NSArray /* SKYUser */ *)users
{
    NSMutableDictionary *usersByEmail = [NSMutableDictionary dictionaryWithCapacity:users.count];
    for (SKYUser *user in users) {
        if (user.email.length) {
            usersByEmail[user.email] = user;
        }
    }
    return usersByEmail;
}

@end
