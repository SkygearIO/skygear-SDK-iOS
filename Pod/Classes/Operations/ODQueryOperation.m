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

- (instancetype)initWithQuery:(ODQuery *)query {
    self = [super init];
    if (self) {
        _query = query;
    }
    return self;
}

- (instancetype)initWithCursor:(ODQueryCursor *)cursor {
    self = [super init];
    if (self) {
        _cursor = cursor;
    }
    return self;
}

- (void)prepareForRequest
{
    ODQuerySerializer *serializer = [ODQuerySerializer serializer];
    NSMutableDictionary *payload = [@{
                                      @"database_id": self.database.databaseID,
                                      @"record_type": self.query.recordType,
                                      @"predicate": [serializer serializeWithPredicate:self.query.predicate],
                                      } mutableCopy];
    if ([self.query.sortDescriptors count] > 0) {
        payload[@"sort"] = [serializer serializeWithSortDescriptors:self.query.sortDescriptors];
    }
    if (self.query.eagerLoadKeyPath) {
        NSArray *keys = [self.query.eagerLoadKeyPath componentsSeparatedByString:@"."];
        if ([keys count] > 1) {
            NSLog(@"Eager loading doesn't support key paths with length more than 1.");
        }
        if ([keys count] > 0) {
            payload[@"eager"] = @[[serializer serializeWithExpression:
                                   [NSExpression expressionForKeyPath:keys[0]]]];
        }
    }
    self.request = [[ODRequest alloc] initWithAction:@"record:query"
                                             payload:payload];
    self.request.accessToken = self.container.currentAccessToken;
}

- (void)setPerRecordCompletionBlock:(void (^)(ODRecord *))perRecordCompletionBlock
{
    [self willChangeValueForKey:@"perRecordCompletionBlock"];
    _perRecordCompletionBlock = perRecordCompletionBlock;
    [self updateCompletionBlock];
    [self didChangeValueForKey:@"perRecordCompletionBlock"];
}

- (void)setQueryRecordsCompletionBlock:(void (^)(NSArray *, ODQueryCursor *, NSError *))queryRecordsCompletionBlock
{
    [self willChangeValueForKey:@"queryRecordsCompletionBlock"];
    _queryRecordsCompletionBlock = queryRecordsCompletionBlock;
    [self updateCompletionBlock];
    [self didChangeValueForKey:@"queryRecordsCompletionBlock"];
}

- (NSArray *)processResultArray:(NSArray *)result
{
    NSMutableArray *fetchedRecords = [NSMutableArray array];
    ODRecordDeserializer *deserializer = [ODRecordDeserializer deserializer];
    
    [result enumerateObjectsUsingBlock:^(NSDictionary *obj, NSUInteger idx, BOOL *stop) {
        NSError *error = nil;
        ODRecord *record = nil;
        ODRecordID *recordID = [ODRecordID recordIDWithCanonicalString:obj[ODRecordSerializationRecordIDKey]];
        
        if (recordID) {
            if ([obj[ODRecordSerializationRecordTypeKey] isEqualToString:@"record"]) {
                record = [deserializer recordWithDictionary:obj];
            } else if ([obj[ODRecordSerializationRecordTypeKey] isEqualToString:@"error"]) {
                // not expecting an error here.
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
            if (self.perRecordCompletionBlock) {
                self.perRecordCompletionBlock(record);
            }
        }
    }];
    
    return fetchedRecords;
}

- (void)updateCompletionBlock
{
    if (self.perRecordCompletionBlock || self.queryRecordsCompletionBlock) {
        __weak typeof(self) weakSelf = self;
        self.completionBlock = ^{
            NSArray *resultArray = nil;
            NSError *error = weakSelf.error;
            if (!error) {
                NSArray *responseArray = weakSelf.response[@"result"];
                if ([responseArray isKindOfClass:[NSArray class]]) {
                    resultArray = [weakSelf processResultArray:responseArray];
                } else {
                    NSDictionary *userInfo = [weakSelf errorUserInfoWithLocalizedDescription:@"Server returned malformed result."
                                                                             errorDictionary:nil];
                    error = [NSError errorWithDomain:(NSString *)ODOperationErrorDomain
                                                code:0
                                            userInfo:userInfo];
                }
            }

            if (weakSelf.queryRecordsCompletionBlock) {
                weakSelf.queryRecordsCompletionBlock(resultArray, nil, error);
            }
        };
    }
}

@end
