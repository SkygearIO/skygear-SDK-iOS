//
//  ODRecord.h
//  askq
//
//  Created by Kenji Pa on 16/1/15.
//  Copyright (c) 2015 Rocky Chan. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ODAccessControl.h"
#import "ODRecordID.h"
#import "ODUserRecordID.h"

extern NSString * const ODRecordTypeUserRecord;

@interface ODRecord : NSObject<NSCopying>

+ (instancetype)recordWithRecordType:(NSString *)recordType;
+ (instancetype)recordWithRecordType:(NSString *)recordType name:(NSString *)recordName;
+ (instancetype)recordWithRecordType:(NSString *)recordType name:(NSString *)recordName data:(NSDictionary *)data;
+ (instancetype)recordWithRecordID:(ODRecordID *)recordId data:(NSDictionary *)data;

/**
 Instantiates an instance of <ODRecord> with the specified record type with a randomly generated <ODRecordID>.
 
 @param recordType Record type of the record.
 @return An instance of ODRecord.
 */
- (instancetype)initWithRecordType:(NSString *)recordType;
- (instancetype)initWithRecordType:(NSString *)recordType name:(NSString *)recordName;
- (instancetype)initWithRecordType:(NSString *)recordType recordID:(ODRecordID *)recordId __deprecated;
- (instancetype)initWithRecordType:(NSString *)recordType recordID:(ODRecordID *)recordId data:(NSDictionary *)data __deprecated;
- (instancetype)initWithRecordType:(NSString *)recordType name:(NSString *)recordName data:(NSDictionary *)data;
- (instancetype)initWithRecordID:(ODRecordID *)recordId data:(NSDictionary *)data NS_DESIGNATED_INITIALIZER;

- (id)objectForKey:(id)key;
- (id)objectForKeyedSubscript:(id)key;

- (void)setObject:(id)object forKey:(id <NSCopying>)key;
- (void)setObject:(id)object forKeyedSubscript:(id <NSCopying>)key;

- (void)addObject:(id)object forKey:(id <NSCopying>)key;
- (void)addObjectsFromArray:(NSArray *)objects forKey:(id <NSCopying>)key;
- (void)removeObject:(id)object forKey:(id <NSCopying>)key;
- (void)removeObjectsFromArray:(NSArray *)objects forKey:(id <NSCopying>)key;

- (ODRecord *)referencedRecordForKey:(id)key;

// increment integer value stored in key by 1
// if the value of key is nil, it is then treated as zero
- (void)incrementKey:(id<NSCopying>)key;
- (void)incrementKey:(id<NSCopying>)key amount:(NSInteger)amount;

// work similarly as incrementKey: but also capacable to
// increment integer value stored within a dictionary accessible by KVC
// intermediate keys that do not exist beforehand will be created automatically
- (void)incrementKeyPath:(id<NSCopying>)keyPath;
- (void)incrementKeyPath:(id<NSCopying>)keyPath amount:(NSInteger)amount;

@property (nonatomic, readonly, copy) ODRecordID *recordID;
@property (nonatomic, readonly, copy) NSString *recordType;
@property (nonatomic, readonly, copy) NSDate *creationDate;
@property (nonatomic, readonly, copy) ODUserRecordID *creatorUserRecordID;
@property (nonatomic, readonly, copy) NSDate *modificationDate;
@property (nonatomic, readonly, copy) ODUserRecordID *lastModifiedUserRecordID;
@property (nonatomic, readonly, copy) NSString *recordChangeTag;
@property (strong, nonatomic, readonly) ODAccessControl *accessControl;
@property (nonatomic, readonly, copy) NSDictionary *dictionary;

@end
