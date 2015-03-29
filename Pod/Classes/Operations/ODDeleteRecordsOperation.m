//
//  ODDeleteRecordsOperation.m
//  Pods
//
//  Created by Patrick Cheung on 1/3/15.
//
//

#import "ODDeleteRecordsOperation.h"
#import "ODRecordSerialization.h"

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

- (void)processResultArray:(NSArray *)result
{
    NSMutableArray *deletedRecordIDs = [self.recordIDs mutableCopy];
    [result enumerateObjectsUsingBlock:^(NSDictionary *obj, NSUInteger idx, BOOL *stop) {
        ODRecordID *recordID = [[ODRecordID alloc] initWithCanonicalString:obj[ODRecordSerializationRecordIDKey]];
        if (self.perRecordCompletionBlock) {
            self.perRecordCompletionBlock(recordID, nil);
        }
        [deletedRecordIDs removeObject:recordID];
    }];
    
    if (self.perRecordCompletionBlock) {
        [deletedRecordIDs enumerateObjectsUsingBlock:^(ODRecordID *recordID, NSUInteger idx, BOOL *stop) {
            self.perRecordCompletionBlock(recordID, nil);
        }];
    }
    
    if (self.deleteRecordsCompletionBlock) {
        self.deleteRecordsCompletionBlock(deletedRecordIDs, nil);
    }
}

- (void)updateCompletionBlock
{
    if (self.perRecordCompletionBlock || self.deleteRecordsCompletionBlock) {
        __weak typeof(self) weakSelf = self;
        self.completionBlock = ^{
            if (weakSelf.error) {
                if (weakSelf.deleteRecordsCompletionBlock) {
                    weakSelf.deleteRecordsCompletionBlock(nil, weakSelf.error);
                }
            } else {
                [weakSelf processResultArray:weakSelf.response[@"result"]];
            }
        };
    }

}

@end
