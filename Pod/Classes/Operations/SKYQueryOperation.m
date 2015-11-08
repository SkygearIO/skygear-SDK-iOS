//
//  SKYQueryOperation.m
//  askq
//
//  Created by Kenji Pa on 21/1/15.
//  Copyright (c) 2015 Rocky Chan. All rights reserved.
//

#import "SKYQueryOperation.h"
#import "SKYRecordDeserializer.h"
#import "SKYFollowQuery.h"
#import "SKYQuerySerializer.h"
#import "SKYRecordSerialization.h"
#import "SKYDataSerialization.h"

@interface SKYQueryOperation()

@property SKYQueryCursor *cursor;

@end

@implementation SKYQueryOperation

- (instancetype)initWithQuery:(SKYQuery *)query
{
    self = [super init];
    if (self) {
        _query = query;
    }
    return self;
}

- (instancetype)initWithCursor:(SKYQueryCursor *)cursor
{
    self = [super init];
    if (self) {
        _cursor = cursor;
    }
    return self;
}

+ (instancetype)operationWithQuery:(SKYQuery *)query
{
    return [[self alloc] initWithQuery:query];
}

+ (instancetype)operationWithCursor:(SKYQueryCursor *)cursor
{
    return [[self alloc] initWithCursor:cursor];
}

- (void)prepareForRequest
{
    SKYQuerySerializer *serializer = [SKYQuerySerializer serializer];
    NSMutableDictionary *payload = [serializer serializeWithQuery:self.query];
    payload[@"database_id"] = self.database.databaseID;
    self.request = [[SKYRequest alloc] initWithAction:@"record:query"
                                             payload:payload];

    self.request.APIKey = self.container.APIKey;
    self.request.accessToken = self.container.currentAccessToken;
}

- (NSArray *)processResultArray:(NSArray *)result perRecordBlock:(void (^)(SKYRecord *record))perRecordBlock
{
    NSMutableArray *fetchedRecords = [NSMutableArray array];
    SKYRecordDeserializer *deserializer = [SKYRecordDeserializer deserializer];
    
    [result enumerateObjectsUsingBlock:^(NSDictionary *obj, NSUInteger idx, BOOL *stop) {
        NSError *error = nil;
        SKYRecord *record = nil;
        SKYRecordID *recordID = [SKYRecordID recordIDWithCanonicalString:obj[SKYRecordSerializationRecordIDKey]];
        
        if (recordID) {
            NSString *type = obj[SKYRecordSerializationRecordTypeKey];
            if ([type isEqualToString:@"record"]) {
                record = [deserializer recordWithDictionary:obj];
                
                if (!record) {
                    NSLog(@"Warning: Received malformed record dictionary.");
                }
            } else {
                // not expecting an error here.
                NSLog(@"Warning: Received dictionary with unexpected value (%@) in `%@` key.", type, SKYRecordSerializationRecordTypeKey);
            }
        } else {
            NSMutableDictionary *userInfo = [self errorUserInfoWithLocalizedDescription:@"Missing `_id` or not in correct format."
                                                                        errorDictionary:nil];
            error = [NSError errorWithDomain:(NSString *)SKYOperationErrorDomain
                                        code:0
                                    userInfo:userInfo];
        }
        
        if (record) {
            [fetchedRecords addObject:record];
            if (perRecordBlock) {
                perRecordBlock(record);
            }
        }
    }];
    
    return fetchedRecords;
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

- (void)handleRequestError:(NSError *)error
{
    if (self.queryRecordsCompletionBlock) {
        self.queryRecordsCompletionBlock(nil, nil, error);
    }
}

- (void)handleResponse:(SKYResponse *)responseObject
{
    NSDictionary *response = responseObject.responseDictionary;
    NSArray *resultArray;
    NSError *error = nil;
    NSArray *responseArray = response[@"result"];
    
    [self processResultInfo:response[@"info"]];

    if ([responseArray isKindOfClass:[NSArray class]]) {
        resultArray = [self processResultArray:responseArray perRecordBlock:^(SKYRecord *record) {
            if (self.perRecordCompletionBlock) {
                self.perRecordCompletionBlock(record);
            }
        }];
    } else {
        NSDictionary *userInfo = [self errorUserInfoWithLocalizedDescription:@"Server returned malformed result."
                                                             errorDictionary:nil];
        error = [NSError errorWithDomain:(NSString *)SKYOperationErrorDomain
                                    code:0
                                userInfo:userInfo];
    }
    
    if (self.queryRecordsCompletionBlock) {
        self.queryRecordsCompletionBlock(resultArray, nil, error);
    }
}

@end
