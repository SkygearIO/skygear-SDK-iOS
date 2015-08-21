//
//  ODRecordStorageSqliteStore.m
//  Pods
//
//  Created by atwork on 16/5/15.
//
//

#import "ODRecordStorageSqliteStore.h"
#import <FMDB/FMDB.h>
#import "ODRecord.h"
#import "ODRecordSerializer.h"
#import "ODRecordDeserializer.h"
#import "ODRecordChange_Private.h"

@implementation ODRecordStorageSqliteStore {
    NSString *_path;
    FMDatabase *_db;
    ODRecordSerializer *_serializer;
    ODRecordDeserializer *_deserializer;
    NSMutableArray *_availableRecordTypes;
}

- (instancetype)initWithFile:(NSString *)path
{
    self = [super init];
    if (self) {
        _path = path;
        _serializer = [ODRecordSerializer serializer];
        _serializer.serializeTransientDictionary = YES;
        _deserializer = [ODRecordDeserializer deserializer];
        _availableRecordTypes = [NSMutableArray array];
        [self prepareForPersistentStorage];
        [self load];
    }
    return self;
}

- (void)prepareForPersistentStorage
{
    _db = [FMDatabase databaseWithPath:_path];
}

- (void)load
{
    [_db open];
    [self createPendingChangesTableWithError:nil];
    [self _purgeFinishedChangesWithError:nil];
    _availableRecordTypes = [[self allRecordTypes] mutableCopy];
}

- (BOOL)purgeWithError:(NSError **)error
{
    [_db close];
    return [[NSFileManager defaultManager] removeItemAtPath:_path error:error];
}

#pragma mark - 

- (BOOL)existsTable:(NSString *)tableName
{
    NSString *stmt = @"SELECT count(*) FROM sqlite_master WHERE type='table' AND name=?";
    FMResultSet *s = [_db executeQuery:stmt, tableName];
    if ([s next]) {
        return (bool)[s intForColumnIndex:0];
    } else {
        return NO;
    }
}

- (NSArray *)allRecordTypes
{
    NSString *stmt = @"SELECT name FROM sqlite_master "
    "WHERE type='table' AND name NOT LIKE '\\_%' ESCAPE '\\' AND name NOT LIKE 'sqlite\\_%' ESCAPE '\\'";
    
    NSMutableArray *recordTypes = [NSMutableArray array];
    FMResultSet *s = [_db executeQuery:stmt];
    while ([s next]) {
        [recordTypes addObject:[s stringForColumnIndex:0]];
    }
    return [recordTypes copy];
}

- (BOOL)createTableWithRecordType:(NSString *)recordType error:(NSError **)error
{
    NSString *stmt = [NSString stringWithFormat:@"CREATE TABLE %@ ("
                      "id INTEGER PRIMARY KEY AUTOINCREMENT, "
                      "name TEXT, "
                      "json BLOB, "
                      "deleted INTEGER, "
                      "local INTEGER, "
                      "overlay_id INTEGER"
                      ");", recordType];
    
    BOOL success = [_db executeUpdate:stmt, recordType];
    if (success) {
        [_availableRecordTypes addObject:recordType];
    } else {
        if (error) {
            *error = [_db lastError];
        }
    }
    return success;
}

- (BOOL)createPendingChangesTableWithError:(NSError **)error
{
    if ([self existsTable:@"_pendingChanges"]) {
        return YES;
    }
    NSString *stmt = @"CREATE TABLE _pendingChanges ("
                      "id INTEGER PRIMARY KEY AUTOINCREMENT, "
                      "recordID TEXT, "
                      "attributesToSave BLOB, "
                      "action INTEGER, "
                      "finished INTEGER, "
                      "resolveMethod INTEGER, "
                      "error BLOB"
                      ");";
    
    BOOL success = [_db executeUpdate:stmt];
    if (!success) {
        if (error) {
            *error = [_db lastError];
        }
    }
    return success;
}
    
- (BOOL)checkTableWithRecordType:(NSString *)recordType autoCreate:(BOOL)autoCreate
{
    BOOL exists = [_availableRecordTypes containsObject:recordType];
    if (!exists && autoCreate) {
        exists = [self createTableWithRecordType:recordType
                                           error:nil];
    }
    return exists;
}

#pragma mark -

- (BOOL)_updatePermanentRowWithRecordID:(ODRecordID *)recordID
                           overlayRowID:(NSInteger)newRowID
                                  error:(NSError **)error
{
    NSString *recordType = recordID.recordType;
    NSString *stmt = [NSString stringWithFormat:
                            @"UPDATE %@ SET overlay_id=? WHERE name=? AND local=0", recordType];
    BOOL success = [_db executeUpdate:stmt,
                    newRowID ? @(newRowID) : 0,
                    recordID.recordName];
    if (!success && error) {
        *error = [_db lastError];
    }
    return success;
}

- (BOOL)_deleteAllRowsWithRecordID:(ODRecordID *)recordID
                         localOnly:(BOOL)localOnly
                             error:(NSError **)error
{
    NSString *recordType = recordID.recordType;
    BOOL success;
    if (localOnly) {
        NSString *stmt = [NSString stringWithFormat:@"DELETE FROM %@ WHERE name=? AND local=?;",
                          recordType];
        
        success = [_db executeUpdate:stmt, recordID.recordName, @(localOnly)];
    } else {
        NSString *stmt = [NSString stringWithFormat:@"DELETE FROM %@ WHERE name=?;",
                          recordType];
        
        success = [_db executeUpdate:stmt, recordID.recordName];
    }
    
    if (!success && error) {
        *error = [_db lastError];
    }
    return success;
}

- (BOOL)_createOrUpdateRowWithRecordID:(ODRecordID *)recordID
                                record:(ODRecord *)record
                               deleted:(BOOL)deleted
                                 local:(BOOL)local
                                 error:(NSError **)error
{
    NSAssert(record || deleted, @"Must supply either record object or set deleted to YES.");
    
    NSString *recordType = recordID.recordType;
    NSString *stmt = [NSString stringWithFormat:
                      @"SELECT * from %@ WHERE name = ? AND local = ?", recordType];
    FMResultSet *s = [_db executeQuery:stmt, recordID.recordName, @(local)];
    BOOL success;
    if ([s next]) {
        NSString *updateStmt = [NSString stringWithFormat:
                                @"UPDATE %@ SET json=?, deleted=?, local=?, overlay_id=?"
                                "WHERE id=?", recordType];
        success = [_db executeUpdate:updateStmt,
                   record ? [_serializer JSONDataWithRecord:record error:nil] : nil,
                   @(deleted),
                   @(local),
                   nil,
                   @([s intForColumn:@"id"])
                   ];
        if (!success && error) {
            *error = [_db lastError];
        }
    } else {
        NSString *insertStmt = [NSString stringWithFormat:
                                @"INSERT INTO %@ "
                                "(name, json, deleted, local) VALUES "
                                @"(?, ?, ?, ?)", recordType];
        success = [_db executeUpdate:insertStmt,
                   recordID.recordName,
                   record ? [_serializer JSONDataWithRecord:record error:nil] : nil,
                   @(deleted),
                   @(local)];
        if (success && local) {
            success = [self _updatePermanentRowWithRecordID:recordID
                                               overlayRowID:[_db lastInsertRowId]
                                                      error:error];
        } else if (!success && error) {
            *error = [_db lastError];
        }
    }
    return success;

}

- (void)saveRecord:(ODRecord *)record
{
    NSString *recordType = record.recordID.recordType;
    [self checkTableWithRecordType:recordType autoCreate:YES];
    
    [self beginTransactionIfNotAlready];
    
    [self _deleteAllRowsWithRecordID:record.recordID localOnly:YES error:nil];
    [self _createOrUpdateRowWithRecordID:record.recordID
                                  record:record
                                 deleted:NO
                                   local:NO
                                   error:nil];
}

- (void)saveRecordLocally:(ODRecord *)record
{
    NSString *recordType = record.recordID.recordType;
    [self checkTableWithRecordType:recordType autoCreate:YES];
    
    [self beginTransactionIfNotAlready];
    
    [self _createOrUpdateRowWithRecordID:record.recordID
                                  record:record
                                 deleted:NO
                                   local:YES
                                   error:nil];
}

- (void)deleteRecord:(ODRecord *)record
{
    [self deleteRecordWithRecordID:record.recordID];
}

- (void)deleteRecordWithRecordID:(ODRecordID *)recordID
{
    NSString *recordType = recordID.recordType;
    if (![self checkTableWithRecordType:recordType autoCreate:NO]) {
        return;
    }
    
    [self beginTransactionIfNotAlready];
    [self _deleteAllRowsWithRecordID:recordID
                           localOnly:NO
                               error:nil];
}

- (void)deleteRecordLocally:(ODRecord *)record
{
    [self deleteRecordLocallyWithRecordID:record.recordID];
}

- (void)deleteRecordLocallyWithRecordID:(ODRecordID *)recordID
{
    NSString *recordType = recordID.recordType;
    if (![self checkTableWithRecordType:recordType autoCreate:NO]) {
        return;
    }
    
    [self beginTransactionIfNotAlready];
    
    [self _createOrUpdateRowWithRecordID:recordID
                                  record:nil
                                 deleted:YES
                                   local:YES
                                   error:nil];
}

- (void)revertRecordLocallyWithRecordID:(ODRecordID *)recordID
{
    [self _deleteAllRowsWithRecordID:recordID
                           localOnly:YES
                               error:nil];
    [self _updatePermanentRowWithRecordID:recordID
                             overlayRowID:0
                                    error:nil];
}

- (ODRecord *)fetchRecordWithRecordID:(ODRecordID *)recordID
{
    NSString *recordType = recordID.recordType;
    if (![self checkTableWithRecordType:recordType autoCreate:NO]) {
        return nil;
    }
    
    NSString *stmt = [NSString stringWithFormat:@"SELECT id, json FROM %@ "
                      "WHERE name=? AND overlay_id IS NULL AND deleted=0;", recordType];
    
    FMResultSet *s = [_db executeQuery:stmt, recordID.recordName];
    if ([s next]) {
        NSData *data = [s dataForColumn:@"json"];
        if (data) {
            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data
                                                                 options:0
                                                                   error:nil];
            ODRecord *record = [_deserializer recordWithDictionary:json];
            return record;
        } else {
            NSLog(@"%@: Record row %d (Record ID: %@) has empty json data.",
                  self, [s intForColumn:@"id"], recordID.canonicalString);
            return nil;
        }
    } else {
        return nil;
    }
}

- (BOOL)existsRecordWithRecordID:(ODRecordID *)recordID
{
    NSString *recordType = recordID.recordType;
    if (![self checkTableWithRecordType:recordType autoCreate:NO]) {
        return NO;
    }
    
    NSString *stmt = [NSString stringWithFormat:@"SELECT count(*) FROM %@ "
                      "WHERE name=? AND overlay_id IS NULL AND deleted=0;",
                      recordType];
    
    FMResultSet *s = [_db executeQuery:stmt, recordType, recordID.recordName];
    if ([s next]) {
        return (bool)[s intForColumnIndex:0];
    } else {
        return NO;
    }
}

- (NSArray *)recordIDsWithRecordType:(NSString *)recordType
{
    if (![self checkTableWithRecordType:recordType autoCreate:NO]) {
        return [NSArray array];
    }
    
    NSString *stmt = [NSString stringWithFormat:@"SELECT name FROM %@ "
                      "WHERE overlay_id IS NULL AND deleted=0;", recordType];
    
    FMResultSet *s = [_db executeQuery:stmt];
    NSMutableArray *result = [[NSMutableArray alloc] init];
    while ([s next]) {
        ODRecordID *recordID = [[ODRecordID alloc] initWithRecordType:recordType
                                                                 name:[s stringForColumnIndex:0]];
        [result addObject:recordID];
    }
    return result;
}

- (void)enumerateRecordsWithBlock:(void (^)(ODRecord *, BOOL *stop))block
{
    if (!block) {
        return;
    }
    
    [[self allRecordTypes] enumerateObjectsUsingBlock:^(NSString *recordType,
                                                        NSUInteger idx, BOOL *stop) {
        [self enumerateRecordsWithType:recordType
                             predicate:nil
                       sortDescriptors:nil
                            usingBlock:block];
    }];
}

- (void)enumerateRecordsWithType:(NSString *)recordType
                       predicate:(NSPredicate *)predicate
                 sortDescriptors:(NSArray *)sortDescriptors
                      usingBlock:(void (^)(ODRecord *, BOOL *))block
{
    if (!block) {
        return;
    }

    if (![self checkTableWithRecordType:recordType autoCreate:NO]) {
        return;
    }
    
    NSString *stmt = [NSString stringWithFormat:@"SELECT id, name, json, overlay_id FROM %@ "
                      "WHERE overlay_id IS NULL AND deleted=0;", recordType];
    
    FMResultSet *s = [_db executeQuery:stmt];
    NSMutableArray *result = [[NSMutableArray alloc] init];
    while ([s next]) {
        NSData *data = [s dataForColumn:@"json"];
        if (data) {
            ODRecord *record = [_deserializer recordWithJSONData:data
                                                           error:nil];
            NSAssert(record, nil);
            BOOL stop = NO;
            if (!predicate || [predicate evaluateWithObject:record]) {
                if ([sortDescriptors count]) {
                    [result addObject:record];
                } else {
                    block(record, &stop);
                }
            }
            if (stop) {
                return;
            }
        } else {
            NSLog(@"%@: Record row %d (Record ID: %@/%@) has empty json data.",
                  self, [s intForColumn:@"id"], recordType, [s stringForColumn:@"name"]);
        }
    }
    
    if ([sortDescriptors count]) {
        [result sortUsingDescriptors:sortDescriptors];
        [result enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            block(obj, stop);
        }];
    }
}

- (void)beginTransactionIfNotAlready
{
    if (![_db inTransaction]) {
        [_db beginTransaction];
    }
}

- (void)synchronize
{
    if (![_db inTransaction]) {
        return;
    }
    
    [_db commit];
}

#pragma mark -

- (void)appendChange:(ODRecordChange *)change
{
    [self beginTransactionIfNotAlready];
    
    NSString *stmt = @"INSERT INTO _pendingChanges "
    "(recordID, attributesToSave, action, finished, resolveMethod, error) VALUES "
    "(?, ?, ?, ?, ?, ?);";
    
    BOOL success = [_db executeUpdate:stmt,
                    change.recordID.canonicalString,
                    [NSKeyedArchiver archivedDataWithRootObject:change.attributesToSave],
                    [NSNumber numberWithInt:change.action],
                    [NSNumber numberWithBool:change.finished],
                    [NSNumber numberWithInt:change.resolveMethod],
                    change.error ? [NSKeyedArchiver archivedDataWithRootObject:change.error] : nil];
    NSAssert(success, @"handle insert failure not implemented");

    [self synchronize];
}

- (void)removeChange:(ODRecordChange *)change
{
    [self beginTransactionIfNotAlready];
    
    NSString *stmt = @"DELETE FROM _pendingChanges WHERE recordID = ?";
    
    BOOL success = [_db executeUpdate:stmt, change.recordID.canonicalString];
    NSAssert(success, @"handle delete failure not implemented");

    [self synchronize];
}

- (BOOL)_purgeFinishedChangesWithError:(NSError **)error
{
    NSString *stmt = @"DELETE FROM _pendingChanges WHERE finished = ? AND error IS NULL";
    
    BOOL success = [_db executeUpdate:stmt, @(YES)];
    if (!success && error) {
        *error = [_db lastError];
    }
    return success;
}

- (BOOL)_updateIsFinished:(BOOL)finished
              changeError:(NSError *)error
                 ofChange:(ODRecordChange *)change
            databaseError:(NSError **)databaseError
{
    NSString *stmt = @"UPDATE _pendingChanges SET finished=?, error=? WHERE recordID = ?";
    
    BOOL success = [_db executeUpdate:stmt,
                    @(finished),
                    error ? [NSKeyedArchiver archivedDataWithRootObject:error] : nil,
                    change.recordID.canonicalString];
    if (!success && databaseError) {
        *databaseError = [_db lastError];
    }
    return success;
}

- (void)setFinishedWithError:(NSError *)error change:(ODRecordChange *)change
{
    change.finished = YES;
    change.error = error;
    [self beginTransactionIfNotAlready];
    [self _updateIsFinished:YES
                changeError:error
                   ofChange:change
              databaseError:nil];
    [self synchronize];
}

- (ODRecordChange *)_changeWithResultSet:(FMResultSet *)s
{
    NSDictionary *attributesToSave = [NSKeyedUnarchiver unarchiveObjectWithData:
                                      [s dataForColumn:@"attributesToSave"]];
    ODRecordID *recordID = [[ODRecordID alloc] initWithCanonicalString:
                            [s stringForColumn:@"recordID"]];
    ODRecordChange *change = [[ODRecordChange alloc]
                              initWithRecordID:recordID
                              action:[s intForColumn:@"action"]
                              resolveMethod:[s intForColumn:@"resolveMethod"]
                              attributesToSave:attributesToSave];
    change.finished = [s boolForColumn:@"finished"];
    if ([s dataForColumn:@"error"]) {
        change.error = [NSKeyedUnarchiver unarchiveObjectWithData:[s dataForColumn:@"error"]];
    }
    return change;
}

- (ODRecordChange *)changeWithRecordID:(ODRecordID *)recordID
{
    NSString *stmt = @"SELECT * FROM _pendingChanges WHERE recordID=?;";
    
    FMResultSet *s = [_db executeQuery:stmt, recordID.canonicalString];
    if ([s next]) {
        return [self _changeWithResultSet:s];
    } else {
        return nil;
    }
}

- (NSUInteger)pendingChangesCount
{
    NSString *stmt = @"SELECT count(*) FROM _pendingChanges WHERE finished=?;";
    FMResultSet *s = [_db executeQuery:stmt, @(NO)];
    if ([s next]) {
        return (NSUInteger)[s intForColumnIndex:0];
    } else {
        return 0;
    }
}

- (NSArray *)pendingChanges
{
    NSString *stmt = @"SELECT * FROM _pendingChanges WHERE finished=?;";
    
    FMResultSet *s = [_db executeQuery:stmt, @(NO)];
    NSMutableArray *result = [NSMutableArray array];
    while ([s next]) {
        [result addObject:[self _changeWithResultSet:s]];
    }
    return result;
}

- (NSArray *)failedChanges
{
    NSString *stmt = @"SELECT * FROM _pendingChanges WHERE error IS NOT NULL;";
    
    FMResultSet *s = [_db executeQuery:stmt];
    NSMutableArray *result = [NSMutableArray array];
    while ([s next]) {
        [result addObject:[self _changeWithResultSet:s]];
    }
    return result;
}

@end
