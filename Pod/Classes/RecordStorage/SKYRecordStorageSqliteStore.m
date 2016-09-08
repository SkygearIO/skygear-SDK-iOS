//
//  SKYRecordStorageSqliteStore.m
//  SKYKit
//
//  Copyright 2015 Oursky Ltd.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

#import <FMDB/FMDB.h>

#import "SKYDataSerialization.h"
#import "SKYRecord.h"
#import "SKYRecordChange_Private.h"
#import "SKYRecordDeserializer.h"
#import "SKYRecordSerializer.h"
#import "SKYRecordStorageSqliteStore.h"

@implementation SKYRecordStorageSqliteStore {
    NSString *_path;
    FMDatabase *_db;
    SKYRecordSerializer *_serializer;
    SKYRecordDeserializer *_deserializer;
    NSMutableArray *_availableRecordTypes;
    BOOL _opened;
}

- (instancetype)initWithFile:(NSString *)path
{
    self = [super init];
    if (self) {
        _path = path;
        _serializer = [SKYRecordSerializer serializer];
        _serializer.serializeTransientDictionary = YES;
        _deserializer = [SKYRecordDeserializer deserializer];
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
    if (_opened) {
        NSLog(@"Attempting to load RecordStorage backing store %@ but it is already in opened "
              @"state. Continue anyway.",
              self);
    }

    NSLog(@"Loading RecordStorage sqlite backing store at path '%@'.", _path);
    if ([_db open]) {
        _opened = YES;
        NSError *error;
        BOOL success = [self createPendingChangesTableWithError:&error];
        if (!success) {
            NSLog(@"There was an error creating tables at path %@: %@", _path, error);
            return;
        }

        NSLog(
            @"RecordStorage backing store will purge changes that have successfully synchronized.");
        success = [self _purgeFinishedChangesWithError:&error];
        if (!success) {
            NSLog(@"There was an error purging finished changes: %@", error);
            return;
        }

        _availableRecordTypes = [[self allRecordTypes] mutableCopy];
        NSLog(@"Record types in database: %@", _availableRecordTypes);
    } else {
        NSLog(@"Unable to open RecordStorage sqlite backing store: %@", [_db lastError]);
    }
}

- (BOOL)purgeWithError:(NSError **)error
{
    NSLog(@"Closing RecordStorage sqlite backing store at path '%@'.", _path);
    if ([_db close]) {
        _opened = NO;
    } else {
        NSLog(@"Unable to open RecordStorage sqlite backing store: %@", [_db lastError]);
    }
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
                      "WHERE type='table' AND name NOT LIKE '\\_%' ESCAPE '\\' AND name NOT LIKE "
                      "'sqlite\\_%' ESCAPE '\\'";

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
                                                 ");",
                                                recordType];

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
    NSString *probeTable = @"_pendingChanges";
    if ([self existsTable:probeTable]) {
        return YES;
    }

    NSLog(@"Table '%@' not found in database. Creating tables.", probeTable);

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
        exists = [self createTableWithRecordType:recordType error:nil];
    }
    return exists;
}

#pragma mark -

- (BOOL)_updatePermanentRowWithRecordID:(SKYRecordID *)recordID
                           overlayRowID:(int64_t)newRowID
                                  error:(NSError **)error
{
    NSString *recordType = recordID.recordType;
    NSString *stmt = [NSString
        stringWithFormat:@"UPDATE %@ SET overlay_id=? WHERE name=? AND local=0", recordType];
    BOOL success = [_db executeUpdate:stmt, newRowID ? @(newRowID) : 0, recordID.recordName];
    if (!success && error) {
        *error = [_db lastError];
    }
    return success;
}

- (BOOL)_deleteAllRowsWithRecordID:(SKYRecordID *)recordID
                         localOnly:(BOOL)localOnly
                             error:(NSError **)error
{
    NSString *recordType = recordID.recordType;
    BOOL success;
    if (localOnly) {
        NSString *stmt =
            [NSString stringWithFormat:@"DELETE FROM %@ WHERE name=? AND local=?;", recordType];

        success = [_db executeUpdate:stmt, recordID.recordName, @(localOnly)];
    } else {
        NSString *stmt = [NSString stringWithFormat:@"DELETE FROM %@ WHERE name=?;", recordType];

        success = [_db executeUpdate:stmt, recordID.recordName];
    }

    if (!success && error) {
        *error = [_db lastError];
    }
    return success;
}

- (BOOL)_createOrUpdateRowWithRecordID:(SKYRecordID *)recordID
                                record:(SKYRecord *)record
                               deleted:(BOOL)deleted
                                 local:(BOOL)local
                                 error:(NSError **)error
{
    NSAssert(record || deleted, @"Must supply either record object or set deleted to YES.");

    NSString *recordType = recordID.recordType;
    NSString *stmt =
        [NSString stringWithFormat:@"SELECT * from %@ WHERE name = ? AND local = ?", recordType];
    FMResultSet *s = [_db executeQuery:stmt, recordID.recordName, @(local)];
    BOOL success;
    if ([s next]) {
        NSString *updateStmt =
            [NSString stringWithFormat:@"UPDATE %@ SET json=?, deleted=?, local=?, overlay_id=?"
                                        "WHERE id=?",
                                       recordType];
        success =
            [_db executeUpdate:updateStmt,
                               record ? [_serializer JSONDataWithRecord:record error:nil] : nil,
                               @(deleted), @(local), nil, @([s intForColumn:@"id"])];
        if (!success && error) {
            *error = [_db lastError];
        }
    } else {
        NSString *insertStmt = [NSString stringWithFormat:@"INSERT INTO %@ "
                                                           "(name, json, deleted, local) VALUES "
                                                          @"(?, ?, ?, ?)",
                                                          recordType];
        success =
            [_db executeUpdate:insertStmt, recordID.recordName,
                               record ? [_serializer JSONDataWithRecord:record error:nil] : nil,
                               @(deleted), @(local)];
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

- (void)saveRecord:(SKYRecord *)record
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

- (void)saveRecordLocally:(SKYRecord *)record
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

- (void)deleteRecord:(SKYRecord *)record
{
    [self deleteRecordWithRecordID:record.recordID];
}

- (void)deleteRecordWithRecordID:(SKYRecordID *)recordID
{
    NSString *recordType = recordID.recordType;
    if (![self checkTableWithRecordType:recordType autoCreate:NO]) {
        return;
    }

    [self beginTransactionIfNotAlready];
    [self _deleteAllRowsWithRecordID:recordID localOnly:NO error:nil];
}

- (void)deleteRecordLocally:(SKYRecord *)record
{
    [self deleteRecordLocallyWithRecordID:record.recordID];
}

- (void)deleteRecordLocallyWithRecordID:(SKYRecordID *)recordID
{
    NSString *recordType = recordID.recordType;
    if (![self checkTableWithRecordType:recordType autoCreate:NO]) {
        return;
    }

    [self beginTransactionIfNotAlready];

    [self _createOrUpdateRowWithRecordID:recordID record:nil deleted:YES local:YES error:nil];
}

- (void)revertRecordLocallyWithRecordID:(SKYRecordID *)recordID
{
    [self _deleteAllRowsWithRecordID:recordID localOnly:YES error:nil];
    [self _updatePermanentRowWithRecordID:recordID overlayRowID:0 error:nil];
}

- (SKYRecord *)fetchRecordWithRecordID:(SKYRecordID *)recordID
{
    NSString *recordType = recordID.recordType;
    if (![self checkTableWithRecordType:recordType autoCreate:NO]) {
        return nil;
    }

    NSString *stmt =
        [NSString stringWithFormat:@"SELECT id, json FROM %@ "
                                    "WHERE name=? AND overlay_id IS NULL AND deleted=0;",
                                   recordType];

    FMResultSet *s = [_db executeQuery:stmt, recordID.recordName];
    if ([s next]) {
        NSData *data = [s dataForColumn:@"json"];
        if (data) {
            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            SKYRecord *record = [_deserializer recordWithDictionary:json];
            return record;
        } else {
            NSLog(@"%@: Record row %d (Record ID: %@) has empty json data.", self,
                  [s intForColumn:@"id"], recordID.canonicalString);
            return nil;
        }
    } else {
        return nil;
    }
}

- (BOOL)existsRecordWithRecordID:(SKYRecordID *)recordID
{
    NSString *recordType = recordID.recordType;
    if (![self checkTableWithRecordType:recordType autoCreate:NO]) {
        return NO;
    }

    NSString *stmt =
        [NSString stringWithFormat:@"SELECT count(*) FROM %@ "
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
                                                 "WHERE overlay_id IS NULL AND deleted=0;",
                                                recordType];

    FMResultSet *s = [_db executeQuery:stmt];
    NSMutableArray *result = [[NSMutableArray alloc] init];
    while ([s next]) {
        SKYRecordID *recordID =
            [[SKYRecordID alloc] initWithRecordType:recordType name:[s stringForColumnIndex:0]];
        [result addObject:recordID];
    }
    return result;
}

- (void)enumerateRecordsWithBlock:(void (^)(SKYRecord *, BOOL *stop))block
{
    if (!block) {
        return;
    }

    [[self allRecordTypes]
        enumerateObjectsUsingBlock:^(NSString *recordType, NSUInteger idx, BOOL *stop) {
            [self enumerateRecordsWithType:recordType
                                 predicate:nil
                           sortDescriptors:nil
                                usingBlock:block];
        }];
}

- (void)enumerateRecordsWithType:(NSString *)recordType
                       predicate:(NSPredicate *)predicate
                 sortDescriptors:(NSArray *)sortDescriptors
                      usingBlock:(void (^)(SKYRecord *, BOOL *))block
{
    if (!block) {
        return;
    }

    if (![self checkTableWithRecordType:recordType autoCreate:NO]) {
        return;
    }

    NSString *stmt = [NSString stringWithFormat:@"SELECT id, name, json, overlay_id FROM %@ "
                                                 "WHERE overlay_id IS NULL AND deleted=0;",
                                                recordType];

    FMResultSet *s = [_db executeQuery:stmt];
    NSMutableArray *result = [[NSMutableArray alloc] init];
    while ([s next]) {
        NSData *data = [s dataForColumn:@"json"];
        if (data) {
            SKYRecord *record = [_deserializer recordWithJSONData:data error:nil];
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
            NSLog(@"%@: Record row %d (Record ID: %@/%@) has empty json data.", self,
                  [s intForColumn:@"id"], recordType, [s stringForColumn:@"name"]);
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

- (void)appendChange:(SKYRecordChange *)change
{
    [self beginTransactionIfNotAlready];

    NSString *stmt = @"INSERT INTO _pendingChanges "
                      "(recordID, attributesToSave, action, finished, resolveMethod, error) VALUES "
                      "(?, ?, ?, ?, ?, ?);";

    NSData *attributesData = nil;
    if (change.attributesToSave) {
        attributesData = [NSJSONSerialization
            dataWithJSONObject:[SKYDataSerialization serializeObject:change.attributesToSave]
                       options:0
                         error:nil];
    }

    BOOL success __attribute__((unused)) =
        [_db executeUpdate:stmt, change.recordID.canonicalString, attributesData,
                           [NSNumber numberWithInt:change.action],
                           [NSNumber numberWithBool:change.finished],
                           [NSNumber numberWithInt:change.resolveMethod],
                           change.error ? [NSKeyedArchiver archivedDataWithRootObject:change.error]
                                        : nil];
    NSAssert(success, @"handle insert failure not implemented");

    [self synchronize];
}

- (void)removeChange:(SKYRecordChange *)change
{
    [self beginTransactionIfNotAlready];

    NSString *stmt = @"DELETE FROM _pendingChanges WHERE recordID = ?";

    BOOL success __attribute__((unused)) =
        [_db executeUpdate:stmt, change.recordID.canonicalString];
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
                 ofChange:(SKYRecordChange *)change
            databaseError:(NSError **)databaseError
{
    NSString *stmt = @"UPDATE _pendingChanges SET finished=?, error=? WHERE recordID = ?";

    BOOL success =
        [_db executeUpdate:stmt, @(finished),
                           error ? [NSKeyedArchiver archivedDataWithRootObject:error] : nil,
                           change.recordID.canonicalString];
    if (!success && databaseError) {
        *databaseError = [_db lastError];
    }
    return success;
}

- (void)setFinishedWithError:(NSError *)error change:(SKYRecordChange *)change
{
    change.finished = YES;
    change.error = error;
    [self beginTransactionIfNotAlready];
    [self _updateIsFinished:YES changeError:error ofChange:change databaseError:nil];
    [self synchronize];
}

- (SKYRecordChange *)_changeWithResultSet:(FMResultSet *)s
{
    // Deserialize attributesToSave column
    NSDictionary *attributesToSave = [NSDictionary dictionary];
    NSData *attributesToSaveData = [s dataForColumn:@"attributesToSave"];
    if (attributesToSaveData) {
        id deserializedValue =
            [NSJSONSerialization JSONObjectWithData:attributesToSaveData options:0 error:nil];
        attributesToSave = [SKYDataSerialization deserializeObjectWithValue:deserializedValue];
    }

    // Create SKYRecordChange from columns
    SKYRecordID *recordID =
        [[SKYRecordID alloc] initWithCanonicalString:[s stringForColumn:@"recordID"]];
    SKYRecordChange *change =
        [[SKYRecordChange alloc] initWithRecordID:recordID
                                           action:[s intForColumn:@"action"]
                                    resolveMethod:[s intForColumn:@"resolveMethod"]
                                 attributesToSave:attributesToSave];
    change.finished = [s boolForColumn:@"finished"];
    if ([s dataForColumn:@"error"]) {
        change.error = [NSKeyedUnarchiver unarchiveObjectWithData:[s dataForColumn:@"error"]];
    }
    return change;
}

- (SKYRecordChange *)changeWithRecordID:(SKYRecordID *)recordID
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
