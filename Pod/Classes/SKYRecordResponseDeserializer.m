//
//  SKYRecordResponseDeserializer.m
//  SKYKit
//
//  Copyright 2018 Oursky Ltd.
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

#import "SKYRecordResponseDeserializer.h"
#import "SKYErrorCreator.h"
#import "SKYRecordDeserializer.h"
#import "SKYRecordID.h"
#import "SKYRecordSerialization.h"

@implementation SKYRecordResponseDeserializer {
    SKYErrorCreator *errorCreator;
    SKYRecordDeserializer *recordDeserializer;
}

- (instancetype)init
{
    if ((self = [super init])) {
        errorCreator = [[SKYErrorCreator alloc] init];
        recordDeserializer = [SKYRecordDeserializer deserializer];
    }
    return self;
}

- (void)deserializeResponseDictionary:(NSDictionary *)dictionary
                                block:(void (^)(NSString *recordType, NSString *recordID,
                                                SKYRecord *record, NSError *error))block
{
    if (!block) {
        @throw [NSException exceptionWithName:NSGenericException
                                       reason:@"block cannot be nil"
                                     userInfo:nil];
    }

    NSString *recordType = dictionary[SKYRecordSerializationRecordRecordTypeKey];
    NSString *recordID = dictionary[SKYRecordSerializationRecordRecordIDKey];

    if (!recordType) {
        NSString *deprecatedID = dictionary[SKYRecordSerializationRecordIDKey];
        if (deprecatedID) {

            if (![deprecatedID isKindOfClass:[NSString class]]) {
                NSError *error = [errorCreator errorWithCode:SKYErrorInvalidData
                                                     message:@"`_id` not in correct format."];
                block(nil, nil, nil, error);
            }
            SKYRecordID *recordIDobj = [[SKYRecordID alloc]
                initWithCanonicalString:dictionary[SKYRecordSerializationRecordIDKey]];
            recordType = recordIDobj.recordType;
            recordID = recordIDobj.recordName;
        }
    }

    if (![recordType isKindOfClass:[NSString class]]) {
        NSError *error =
            [errorCreator errorWithCode:SKYErrorInvalidData
                                message:@"`_recordType` is missing or not in correct format."];
        block(nil, nil, nil, error);
        return;
    }

    if (![recordID isKindOfClass:[NSString class]]) {
        NSError *error =
            [errorCreator errorWithCode:SKYErrorInvalidData
                                message:@"`_recordID` is missing or not in correct format."];
        block(recordType, nil, nil, error);
        return;
    }

    if ([dictionary[SKYRecordSerializationRecordTypeKey] isEqualToString:@"record"]) {
        SKYRecord *record = [recordDeserializer recordWithDictionary:dictionary];

        if (!record) {
            NSError *error =
                [errorCreator errorWithCode:SKYErrorInvalidData
                                    message:@"`Record dictionary not in correct format."];
            block(recordType, recordID, nil, error);
            return;
        }

        block(recordType, recordID, record, nil);
    } else if ([dictionary[SKYRecordSerializationRecordTypeKey] isEqualToString:@"error"]) {
        NSError *error = [errorCreator errorWithResponseDictionary:dictionary];
        block(recordType, recordID, nil, error);
    } else {
        NSError *error = [errorCreator errorWithCode:SKYErrorInvalidData
                                             message:@"`Record dictionary not in correct format."];
        block(recordType, recordID, nil, error);
    }
}

- (void)deserializeResponseArray:(NSArray<NSDictionary *> *)array
                           block:(void (^)(NSString *recordType, NSString *recordID,
                                           SKYRecord *record, NSError *error))block
{
    for (NSDictionary *dict in array) {
        [self deserializeResponseDictionary:dict block:block];
    }
}

@end
