//
//  SKYUserDeserializer.m
//  Pods
//
//  Created by Kenji Pa on 1/6/15.
//
//

#import "SKYUserDeserializer.h"

#import "SKYUserRecordID_Private.h"

@implementation SKYUserDeserializer

+ (instancetype)deserializer
{
    return [[self alloc] init];
}

- (SKYUser *)userWithDictionary:(NSDictionary *)dictionary
{
    SKYUser *user = nil;

    NSString *userID = dictionary[@"_id"];
    if (userID.length) {
        NSString *email = dictionary[@"email"];
        NSDictionary *authData = dictionary[@"authData"];
        SKYUserRecordID *userRecordID =
            [SKYUserRecordID recordIDWithUsername:userID email:email authData:authData];
        user = [[SKYUser alloc] initWithUserRecordID:userRecordID];
    }

    return user;
}

@end
