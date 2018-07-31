//
//  SKYDatabase.swift
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

import Foundation

extension SKYDatabase {
    public func fetchRecords(type: String, recordIDs: [String], completion: (([SKYRecordResult<SKYRecord>]?, Error?) -> Void)?) {
        __fetchRecords(withType: type, recordIDs: recordIDs) { (results, operationError) in
            guard let completion = completion else {
                return
            }
            if let operationError = operationError {
                completion(nil, operationError)
            } else if let results = results {
                completion(results.map { SKYRecordResult<SKYRecord>.fromObjC($0) }, nil)
            }
        }
    }

    public func saveRecordsNonAtomically(_ records: [SKYRecord], completion: (([SKYRecordResult<SKYRecord>]?, Error?) -> Void)?) {
        __saveRecordsNonAtomically(records) { (results, operationError) in
            guard let completion = completion else {
                return
            }
            if let operationError = operationError {
                completion(nil, operationError)
            } else if let results = results {
                completion(results.map { SKYRecordResult<SKYRecord>.fromObjC($0) }, nil)
            }
        }
    }

    public func deleteRecordsNonAtomically(_ records: [SKYRecord], completion: (([SKYRecordResult<SKYRecord>]?, Error?) -> Void)?) {
        __deleteRecordsNonAtomically(records) { (results, operationError) in
            guard let completion = completion else {
                return
            }
            if let operationError = operationError {
                completion(nil, operationError)
            } else if let results = results {
                completion(results.map { SKYRecordResult<SKYRecord>.fromObjC($0) }, nil)
            }
        }
    }

    public func deleteRecordsNonAtomically(type: String, recordIDs: [String], completion: (([SKYRecordResult<String>]?, Error?) -> Void)?) {
        __deleteRecordsNonAtomically(withType: type, recordIDs: recordIDs) { (results, operationError) in
            guard let completion = completion else {
                return
            }
            if let operationError = operationError {
                completion(nil, operationError)
            } else if let results = results {
                completion(results.map({ (result) -> SKYRecordResult<String> in
                    if let value = result.value {
                        return SKYRecordResult<String>.success(value as String)
                    } else {
                        return SKYRecordResult<String>.error(result.error!)
                    }
                }), nil)
            }
        }
    }
}
