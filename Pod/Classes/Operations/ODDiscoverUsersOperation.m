//
//  ODDiscoverUserOperation.m
//  Pods
//
//  Created by Kenji Pa on 29/5/15.
//
//

#import "ODDiscoverUsersOperation.h"

#import "ODUser.h"
#import "ODUserDeserializer.h"

@interface ODDiscoverUsersOperation()

@property (strong, nonatomic) ODUserDeserializer *deserializer;
@property (nonatomic, readwrite, assign) ODUserDiscoveryMethod discoveryMethod;

@end

@implementation ODDiscoverUsersOperation

+ (instancetype)discoverUsersOperationByEmails:(NSArray *)emails
{
    return [[self alloc] initWithEmails:emails];
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

- (void)prepareForRequest
{
    switch (self.discoveryMethod) {
        case ODUserDiscoveryMethodEmail:
            break;
        default:
            @throw([NSException exceptionWithName:NSInternalInconsistencyException reason:@"Unrecgonized user discovery method" userInfo:@{@"discoveryMethod": @(self.discoveryMethod)}]);
    }

    self.request = [[ODRequest alloc] initWithAction:@"user:query" payload:@{@"emails": self.emails}];
    self.request.accessToken = self.container.currentAccessToken;
}

- (void)handleRequestError:(NSError *)error
{
    if (self.discoverUserCompletionBlock) {
        self.discoverUserCompletionBlock(nil, nil, error);
    }
}

- (void)handleResponse:(NSDictionary *)response
{
    NSArray *result = response[@"result"];
    NSArray *userDicts = [self.class itemDictsFromResult:result];
    NSMutableDictionary *usersByEmail = [NSMutableDictionary dictionaryWithCapacity:userDicts.count];
    for (NSDictionary *userDict in userDicts) {
        ODUser *user = [self.deserializer userWithDictionary:userDict];
        if (!user) {
            NSLog(@"Malformed user: %@", userDict);
            continue;
        }

        if (!user.email.length) {
            NSLog(@"Got user with empty email: %@", user);
            continue;
        }
        usersByEmail[user.email] = user;
    }

    NSMutableArray *discoveredUsers = [NSMutableArray arrayWithCapacity:userDicts.count];
    NSMutableArray *emailsNotFound = [NSMutableArray array];
    for (NSString *email in self.emails) {
        ODUser *user = usersByEmail[email];
        if (user) {
            [discoveredUsers addObject:user];
        } else {
            [emailsNotFound addObject:email];
        }
    }

    if (self.discoverUserCompletionBlock) {
        self.discoverUserCompletionBlock(discoveredUsers, emailsNotFound, nil);
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

@end
