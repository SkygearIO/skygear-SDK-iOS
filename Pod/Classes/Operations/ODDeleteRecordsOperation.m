//
//  ODDeleteRecordsOperation.m
//  Pods
//
//  Created by Patrick Cheung on 1/3/15.
//
//

#import "ODDeleteRecordsOperation.h"
#import "ODRecordSerialization.h"
#import "ODDataSerialization.h"

@implementation ODDeleteRecordsOperation

- (instancetype)initWithRecordIDsToDelete:(NSArray *)recordIDs
{
    self = [super init];
    if (self) {
        self.recordIDs = [recordIDs copy];
    }
    return self;
}

- (void)prepareForRequest
{
    NSMutableArray *stringIDs = [NSMutableArray array];
    [self.recordIDs enumerateObjectsUsingBlock:^(ODRecordID *obj, NSUInteger idx, BOOL *stop) {
        [stringIDs addObject:[obj canonicalString]];
    }];
    NSMutableDictionary *payload = [@{
                                      @"ids": stringIDs,
                                      @"database_id": self.database.databaseID,
                                      } mutableCopy];
    self.request = [[ODRequest alloc] initWithAction:@"record:delete"
                                             payload:payload];
    self.request.accessToken = self.container.currentAccessToken;
}

- (void)setPerRecordCompletionBlock:(void (^)(ODRecordID *, NSError *))perRecordCompletionBlock
{
    [self willChangeValueForKey:@"perRecordCompletionBlock"];
    _perRecordCompletionBlock = perRecordCompletionBlock;
    [self updateCompletionBlock];
    [self didChangeValueForKey:@"perRecordCompletionBlock"];
}

- (void)setDeleteRecordsCompletionBlock:(void (^)(NSArray *, NSError *))deleteRecordsCompletionBlock
{
    [self willChangeValueForKey:@"deleteRecordsCompletionBlock"];
    _deleteRecordsCompletionBlock = deleteRecordsCompletionBlock;
    [self updateCompletionBlock];
    [self didChangeValueForKey:@"deleteRecordsCompletionBlock"];
}

- (NSArray *)processResultArray:(NSArray *)result
{
    NSMutableArray *deletedRecordIDs = [self.recordIDs mutableCopy];
    [result enumerateObjectsUsingBlock:^(NSDictionary *obj, NSUInteger idx, BOOL *stop) {
        NSError *error = nil;
        ODRecordID *recordID = [ODRecordID recordIDWithCanonicalString:obj[ODRecordSerializationRecordIDKey]];
        
        if (recordID) {
            if ([obj[ODRecordSerializationRecordTypeKey] isEqualToString:@"error"]) {
                NSMutableDictionary *userInfo = [ODDataSerialization userInfoWithErrorDictionary:obj];
                userInfo[NSLocalizedDescriptionKey] = @"An error occurred while modifying record.";
                error = [NSError errorWithDomain:(NSString *)ODOperationErrorDomain
                                            code:0
                                        userInfo:userInfo];
            }
        } else {
            NSMutableDictionary *userInfo = [self errorUserInfoWithLocalizedDescription:@"Missing `_id` or not in correct format."
                                                                        errorDictionary:nil];
            error = [NSError errorWithDomain:(NSString *)ODOperationErrorDomain
                                        code:0
                                    userInfo:userInfo];
        }
        
        if (recordID) {
            if (self.perRecordCompletionBlock) {
                self.perRecordCompletionBlock(recordID, error);
            }
            [deletedRecordIDs removeObject:recordID];
        }
    }];

    if (self.perRecordCompletionBlock) {
        [deletedRecordIDs enumerateObjectsUsingBlock:^(ODRecordID *recordID, NSUInteger idx, BOOL *stop) {
            self.perRecordCompletionBlock(recordID, nil);
        }];
    }

    return deletedRecordIDs;
}

- (void)updateCompletionBlock
{
    if (self.perRecordCompletionBlock || self.deleteRecordsCompletionBlock) {
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
            
            if (weakSelf.deleteRecordsCompletionBlock) {
                weakSelf.deleteRecordsCompletionBlock(resultArray, error);
            }
        };
    }

}

@end
