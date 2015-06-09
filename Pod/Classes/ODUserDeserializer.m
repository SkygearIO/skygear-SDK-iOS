//
//  ODUserDeserializer.m
//  Pods
//
//  Created by Kenji Pa on 1/6/15.
//
//

#import "ODUserDeserializer.h"

#import "ODUserRecordID_Private.h"

@implementation ODUserDeserializer

+ (instancetype)deserializer
{
    return [[self alloc] init];
}

- (ODUser *)userWithDictionary:(NSDictionary *)dictionary
{
    ODUser *user = nil;

    NSString *userID = dictionary[@"_id"];
    if (userID.length) {
        NSString *email = dictionary[@"email"];
        NSDictionary *authData = dictionary[@"authData"];
        ODUserRecordID *userRecordID = [ODUserRecordID recordIDWithUsername:userID email:email authData:authData];
        user = [[ODUser alloc] initWithUserRecordID:userRecordID];
    }

    return user;
}

@end
