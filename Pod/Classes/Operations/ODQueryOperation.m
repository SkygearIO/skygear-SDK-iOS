//
//  ODQueryOperation.m
//  askq
//
//  Created by Kenji Pa on 21/1/15.
//  Copyright (c) 2015 Rocky Chan. All rights reserved.
//

#import "ODQueryOperation.h"
#import "ODRecordDeserializer.h"
#import "ODFollowQuery.h"
#import "ODQuerySerializer.h"
#import "ODRecordSerialization.h"
#import "ODDataSerialization.h"

@interface ODQueryOperation()

@property ODQueryCursor *cursor;

@end

@implementation ODQueryOperation

- (instancetype)initWithQuery:(ODQuery *)query
{
    self = [super init];
    if (self) {
        _query = query;
    }
    return self;
}

- (instancetype)initWithCursor:(ODQueryCursor *)cursor
{
    self = [super init];
    if (self) {
        _cursor = cursor;
    }
    return self;
}

+ (instancetype)operationWithQuery:(ODQuery *)query
{
    return [[self alloc] initWithQuery:query];
}

+ (instancetype)operationWithCursor:(ODQueryCursor *)cursor
{
    return [[self alloc] initWithCursor:cursor];
}

- (void)prepareForRequest
{
    ODQuerySerializer *serializer = [ODQuerySerializer serializer];
    NSMutableDictionary *payload = [serializer serializeWithQuery:self.query];
    payload[@"database_id"] = self.database.databaseID;
    self.request = [[ODRequest alloc] initWithAction:@"record:query"
                                             payload:payload];

    self.request.accessToken = self.container.currentAccessToken;
}

- (NSArray *)processResultArray:(NSArray *)result perRecordBlock:(void (^)(ODRecord *record))perRecordBlock
{
    NSMutableArray *fetchedRecords = [NSMutableArray array];
    ODRecordDeserializer *deserializer = [ODRecordDeserializer deserializer];
    
    [result enumerateObjectsUsingBlock:^(NSDictionary *obj, NSUInteger idx, BOOL *stop) {
        NSError *error = nil;
        ODRecord *record = nil;
        ODRecordID *recordID = [ODRecordID recordIDWithCanonicalString:obj[ODRecordSerializationRecordIDKey]];
        
        if (recordID) {
            NSString *type = obj[ODRecordSerializationRecordTypeKey];
            if ([type isEqualToString:@"record"]) {
                record = [deserializer recordWithDictionary:obj];
                
                if (!record) {
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
        
        if (record) {
            [fetchedRecords addObject:record];
            if (perRecordBlock) {
                perRecordBlock(record);
            }
        }
    }];
    
    return fetchedRecords;
}

- (void)handleRequestError:(NSError *)error
{
    if (self.queryRecordsCompletionBlock) {
        self.queryRecordsCompletionBlock(nil, nil, error);
    }
}

- (void)handleResponse:(ODResponse *)responseObject
{
    NSDictionary *response = responseObject.responseDictionary;
    NSArray *resultArray;
    NSError *error = nil;
    NSArray *responseArray = response[@"result"];
    
    if ([responseArray isKindOfClass:[NSArray class]]) {
        resultArray = [self processResultArray:responseArray perRecordBlock:^(ODRecord *record) {
            if (self.perRecordCompletionBlock) {
                self.perRecordCompletionBlock(record);
            }
        }];
    } else {
        NSDictionary *userInfo = [self errorUserInfoWithLocalizedDescription:@"Server returned malformed result."
                                                             errorDictionary:nil];
        error = [NSError errorWithDomain:(NSString *)ODOperationErrorDomain
                                    code:0
                                userInfo:userInfo];
    }
    
    if (self.queryRecordsCompletionBlock) {
        self.queryRecordsCompletionBlock(resultArray, nil, error);
    }
}

@end
