//
//  ODDiscoverUserOperation.m
//  Pods
//
//  Created by Kenji Pa on 29/5/15.
//
//

#import "ODQueryUsersOperation.h"

#import "ODError.h"
#import "ODUser.h"
#import "ODUserDeserializer.h"

NSString * NSStringFromRelationDirection(ODRelationDirection direction) {
    switch (direction) {
        case ODRelationDirectionActive:
            return @"active";
            break;
        case ODRelationDirectionPassive:
            return @"passive";
            break;
        case ODRelationDirectionMutual:
            return @"mutual";
            break;
        default:
            @throw([NSException exceptionWithName:NSInternalInconsistencyException reason:@"Unrecgonized relation direction" userInfo:@{@"relationDirection": @(direction)}]);
    }
}

@interface ODQueryUsersOperation()

@property (strong, nonatomic) ODUserDeserializer *deserializer;
@property (nonatomic, readwrite, assign) ODUserDiscoveryMethod discoveryMethod;

@end

@implementation ODQueryUsersOperation

+ (instancetype)discoverUsersOperationByEmails:(NSArray *)emails
{
    return [[self alloc] initWithEmails:emails];
}

+ (instancetype)queryUsersOperationByRelation:(ODRelation *)relation
{
    return [[self alloc] initWithRelation:relation];
}

+ (instancetype)queryUsersOperationByRelation:(ODRelation *)relation direction:(ODRelationDirection)direction
{
    return [[self alloc] initWithRelation:relation direction:direction];
}

- (instancetype)initWithEmails:(NSArray *)emails
{
    self = [super init];
    if (self) {
        self.deserializer = [ODUserDeserializer deserializer];
        self.discoveryMethod = ODUserDiscoveryMethodEmail;
        self.emails = emails;
    }
    return self;
}

- (instancetype)initWithRelation:(ODRelation *)relation
{
    return [self initWithRelation:relation direction:ODRelationDirectionActive];
}

- (instancetype)initWithRelation:(ODRelation *)relation direction:(ODRelationDirection)direction
{
    self = [super init];
    if (self) {
        self.deserializer = [ODUserDeserializer deserializer];
        self.discoveryMethod = ODUserDiscoveryMethodRelation;
        self.relation = relation;
        self.relationDirection = direction;
    }
    return self;
}

- (void)prepareForRequest
{
    NSString *directionString;

    switch (self.discoveryMethod) {
        case ODUserDiscoveryMethodEmail:
            self.request = [[ODRequest alloc] initWithAction:@"user:query" payload:@{@"emails": self.emails}];
            break;
        case ODUserDiscoveryMethodRelation:
            directionString = NSStringFromRelationDirection(self.relationDirection);
            self.request = [[ODRequest alloc] initWithAction:@"relation:query"
                                                     payload:@{
                                                               @"name": self.relation.name,
                                                               @"direction": directionString,
                                                               }];
            break;
        default:
            @throw([NSException exceptionWithName:NSInternalInconsistencyException reason:@"Unrecgonized user discovery method" userInfo:@{@"discoveryMethod": @(self.discoveryMethod)}]);
    }

    self.request.accessToken = self.container.currentAccessToken;
}

- (void)handleRequestError:(NSError *)error
{
    if (self.queryUserCompletionBlock) {
        self.queryUserCompletionBlock(nil, error);
    }
}

- (void)handleResponse:(NSDictionary *)response
{
    NSArray *result = response[@"result"];
    NSArray *userDicts = [self.class itemDictsFromResult:result];
    NSMutableArray *users = [NSMutableArray arrayWithCapacity:userDicts.count];

    for (NSDictionary *userDict in userDicts) {
        ODUser *user = [self.deserializer userWithDictionary:userDict];
        if (!user) {
            NSLog(@"Malformed user: %@", userDict);
            continue;
        }

        [users addObject:user];
    }

    NSError *error = nil;

    if (self.discoveryMethod == ODUserDiscoveryMethodEmail) {
        NSDictionary *usersByEmail = [self.class usersByEmail:users];

        NSMutableArray *emailsNotFound = [NSMutableArray array];
        for (NSString *email in self.emails) {
            if (usersByEmail[email] == nil) {
                [emailsNotFound addObject:email];
            }
        }

        if (emailsNotFound.count) {
            NSDictionary *userInfo = @{ODPartialEmailsNotFoundKey: emailsNotFound};
            error = [NSError errorWithDomain:ODOperationErrorDomain
                                        code:ODErrorPartialFailure
                                    userInfo:userInfo];
        }
    }

    if (self.perUserCompletionBlock) {
        for (ODUser *user in users) {
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

+ (NSDictionary *)usersByEmail:(NSArray /* ODUser */ *)users
{
    NSMutableDictionary *usersByEmail = [NSMutableDictionary dictionaryWithCapacity:users.count];
    for (ODUser *user in users) {
        if (user.email.length) {
            usersByEmail[user.email] = user;
        }
    }
    return usersByEmail;
}

@end
