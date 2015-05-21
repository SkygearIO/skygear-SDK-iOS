//
//  ODFetchRelationsOperation.m
//  Pods
//
//  Created by Rick Mak on 18/5/15.
//
//

#import "ODQueryRelationsOperation.h"
#import "ODRequest.h"
#import "ODRecordDeserializer.h"
#import "ODRecordSerialization.h"

@interface ODQueryRelationsOperation ()

@property (readonly) NSString *directionString;

@end


@implementation ODQueryRelationsOperation

- (instancetype)initWithType:(NSString *)relationType direction:(ODRelationDirection)direction
{
    if ((self = [super init])) {
        _relationType = relationType;
        _direction = direction;
    }
    return self;
}


- (void)prepareForRequest
{
    self.request = [[ODRequest alloc] initWithAction:@"relation:fetch"
                                             payload:@{
                                                       @"name": self.relationType,
                                                       @"direction": self.directionString
                                                           }];
    self.request.accessToken = self.container.currentAccessToken;
}

- (NSString *)directionString {
    NSString *result = nil;
    
    switch(self.direction) {
        case ODRelationDirectionActive:
            result = @"active";
            break;
        case ODRelationDirectionPassive:
            result = @"passive";
            break;
        case ODRelationDirectionMutual:
            result = @"mutual";
            break;
        default:
            @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                           reason:@"The relation operation reveiced an unsupported direction"
                                         userInfo:nil];
    }
    
    return result;
}

- (NSArray *)processResultArray:(NSArray *)result
{
    NSMutableArray *users = [[NSMutableArray alloc] initWithCapacity:result.count];
    ODRecordDeserializer *deserializer = [ODRecordDeserializer deserializer];
    [result enumerateObjectsUsingBlock:^(NSDictionary *obj, NSUInteger idx, BOOL *stop) {
        NSError *error = nil;
        ODUser *user = nil;
        ODUserRecordID *userID = [ODUserRecordID recordIDWithCanonicalString:obj[ODRecordSerializationRecordIDKey]];
        if (userID) {
            NSString *type = obj[ODRecordSerializationRecordTypeKey];
            if ([type isEqualToString:@"user"]) {
                user = (ODUser *)[deserializer recordWithDictionary:obj];
                
                if (!user) {
                    NSLog(@"Warning: Received malformed record dictionary.");
                }
            } else {
                // not expecting an error here.
                NSLog(@"Warning: Received dictionary with unexpected value (%@) in `%@` key.", type, ODRecordSerializationRecordTypeKey);
            }
        } else {
            NSMutableDictionary *userInfo = [self errorUserInfoWithLocalizedDescription:@"Missing `_id` or not in correct format."
                                                                        errorDictionary:nil];
            error = [NSError errorWithDomain:(NSString *)ODOperationErrorDomain
                                        code:0
                                    userInfo:userInfo];
        }
        if (user) {
            [users addObject:user];
            if (self.perUserCompletionBlock) {
                self.perUserCompletionBlock(user);
            }
        }
    }];
    
    return users;
}

- (void)handleRequestError:(NSError *)error
{
    if (self.queryUsersCompletionBlock) {
        self.queryUsersCompletionBlock(nil, error);
    }
}

- (void)handleResponse:(NSDictionary *)response
{
    NSArray *resultUsers = nil;
    NSError *error = nil;
    NSArray *responseArray = response[@"result"];
    if ([responseArray isKindOfClass:[NSArray class]]) {
        resultUsers = [self processResultArray:responseArray];
    } else {
        NSDictionary *userInfo = [self errorUserInfoWithLocalizedDescription:@"Server returned malformed result."
                                                             errorDictionary:nil];
        error = [NSError errorWithDomain:(NSString *)ODOperationErrorDomain
                                    code:0
                                userInfo:userInfo];
    }
    
    if (self.queryUsersCompletionBlock) {
        self.queryUsersCompletionBlock(resultUsers, error);
    }
}

@end
