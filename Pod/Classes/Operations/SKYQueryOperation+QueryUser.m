//
//  SKYQueryOperation+QueryUser.m
//  Pods
//
//  Created by atwork on 3/2/2016.
//
//

#import "SKYQueryOperation+QueryUser.h"
#import "SKYUserDiscoverPredicate.h"

@implementation SKYQueryOperation (QueryUser)

+ (instancetype)queryUsersOperationByEmails:(NSArray /* NSString */ *)emails
{
    NSPredicate *predicate = [SKYUserDiscoverPredicate predicateWithEmails:emails];
    SKYQuery *query = [SKYQuery queryWithRecordType:@"user" predicate:predicate];
    return [SKYQueryOperation operationWithQuery:query];
}

+ (instancetype)queryUsersOperationByRelation:(SKYRelation *)relation
{
    NSPredicate *predicate = [SKYRelationPredicate predicateWithRelation:relation keyPath:@"_id"];
    SKYQuery *query = [SKYQuery queryWithRecordType:@"user" predicate:predicate];
    return [SKYQueryOperation operationWithQuery:query];
}

@end
