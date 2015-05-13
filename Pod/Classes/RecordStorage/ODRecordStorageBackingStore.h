//
//  ODRecordStorageBackingStore.h
//  Pods
//
//  Created by atwork on 6/5/15.
//
//

#import <Foundation/Foundation.h>

@class ODRecord;
@class ODRecordID;

@protocol ODRecordStorageBackingStore <NSObject>

- (void)insertRecord:(ODRecord *)record;
- (void)updateRecord:(ODRecord *)record;
- (void)deleteRecord:(ODRecord *)record;
- (void)deleteRecordWithRecordID:(ODRecordID *)recordID;
- (ODRecord *)fetchRecordWithRecordID:(ODRecordID *)recordID;
- (BOOL)existsRecordWithRecordID:(ODRecordID *)recordID;
- (NSArray *)queryRecordIDsWithRecordType:(NSString *)recordType;
- (void)synchronize;
- (void)enumerateRecordsWithBlock:(void (^)(ODRecord *record))block;

@end
