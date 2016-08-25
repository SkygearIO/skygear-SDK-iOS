//
//  SKYRecordSerializerTests.m
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

#import <CoreLocation/CoreLocation.h>
#import <Foundation/Foundation.h>
#import <SKYKit/SKYKit.h>

#import "SKYAccessControlEntry.h"
#import "SKYAccessControl_Private.h"
#import "SKYAsset_Private.h"
#import "SKYRecord_Private.h"

SpecBegin(SKYRecordSerializer)

    describe(@"serialize", ^{
        __block SKYRecordSerializer *serializer = nil;
        __block SKYRecord *record = nil;

        beforeEach(^{
            serializer = [SKYRecordSerializer serializer];
            record = [[SKYRecord alloc]
                initWithRecordID:[[SKYRecordID alloc] initWithRecordType:@"book" name:@"book1"]
                            data:nil];

        });

        it(@"init", ^{
            SKYRecordSerializer *serializer = [SKYRecordSerializer serializer];
            expect([serializer class]).to.beSubclassOf([SKYRecordSerializer class]);
        });

        it(@"serialize empty record", ^{
            NSDictionary *dictionary = [serializer dictionaryWithRecord:record];
            expect([dictionary class]).to.beSubclassOf([NSDictionary class]);
            expect(dictionary[SKYRecordSerializationRecordTypeKey]).to.equal(@"record");
            expect(dictionary[SKYRecordSerializationRecordIDKey]).to.equal(@"book/book1");
        });

        it(@"serialize record with null field", ^{
            record[@"null"] = [NSNull null];
            NSDictionary *dictionary = [serializer dictionaryWithRecord:record];
            expect(dictionary[@"null"]).to.equal([NSNull null]);
        });

        it(@"serialize string", ^{
            NSString *bookTitle = @"The tale of two cities";
            [record setObject:bookTitle forKey:@"title"];
            NSDictionary *dictionary = [serializer dictionaryWithRecord:record];
            expect(dictionary[@"title"]).to.equal(bookTitle);
        });

        it(@"serialize asset", ^{
            SKYAsset *asset =
                [SKYAsset assetWithName:@"asset-name"
                                    url:[NSURL URLWithString:@"http://ourd.test/files/asset-name"]];
            [record setObject:asset forKey:@"asset"];
            NSDictionary *dictionary = [serializer dictionaryWithRecord:record];
            expect(dictionary[@"asset"]).to.equal(@{
                @"$type" : @"asset",
                @"$name" : @"asset-name",
            });
        });

        it(@"serialize reference", ^{
            [record
                setObject:[[SKYReference alloc]
                              initWithRecordID:[[SKYRecordID alloc] initWithRecordType:@"author"
                                                                                  name:@"author1"]]
                   forKey:@"author"];
            NSDictionary *dictionary = [serializer dictionaryWithRecord:record];
            NSDictionary *authorRef = dictionary[@"author"];
            expect([authorRef class]).to.beSubclassOf([NSDictionary class]);
            expect(authorRef[SKYDataSerializationCustomTypeKey])
                .to.equal(SKYDataSerializationReferenceType);
            expect(authorRef[@"$id"]).to.equal(@"author/author1");
        });

        it(@"serialize date", ^{
            [record setObject:[NSDate dateWithTimeIntervalSinceReferenceDate:0]
                       forKey:@"published"];
            NSDictionary *dictionary = [serializer dictionaryWithRecord:record];
            NSDictionary *publishDate = dictionary[@"published"];
            expect([publishDate class]).to.beSubclassOf([NSDictionary class]);
            NSLog(@"%@", publishDate);
            expect(publishDate[SKYDataSerializationCustomTypeKey])
                .to.equal(SKYDataSerializationDateType);

            expect([SKYDataSerialization dateFromString:publishDate[@"$date"]])
                .to.equal([NSDate dateWithTimeIntervalSinceReferenceDate:0]);
        });

        it(@"serialize array", ^{
            NSArray *topics = [NSArray arrayWithObjects:@"fiction", @"classic", nil];
            [record setObject:topics forKey:@"topics"];
            NSDictionary *dictionary = [serializer dictionaryWithRecord:record];
            NSArray *serializedTopics = dictionary[@"topics"];
            expect([serializedTopics class]).to.beSubclassOf([NSArray class]);
            expect(serializedTopics).to.equal(topics);
        });

        it(@"serialize public readable access control", ^{
            record.accessControl = [SKYAccessControl publicReadableAccessControl];

            NSDictionary *dictionary = [serializer dictionaryWithRecord:record];
            expect(dictionary[@"_access"]).to.equal(@[ @{ @"public" : @YES, @"level" : @"read" } ]);
        });

        it(@"serialize empty access control", ^{
            record.accessControl = [SKYAccessControl accessControlWithEntries:nil];

            NSDictionary *dictionary = [serializer dictionaryWithRecord:record];
            expect(dictionary[@"_access"]).to.equal(@[]);
        });

        it(@"serialize access control", ^{
            SKYAccessControlEntry *entry =
                [SKYAccessControlEntry writeEntryForRelation:[SKYRelation followedRelation]];
            record.accessControl = [SKYAccessControl accessControlWithEntries:@[ entry ]];

            NSDictionary *dictionary = [serializer dictionaryWithRecord:record];
            expect(dictionary[@"_access"]).to.equal(@[
                @{ @"relation" : @"follow",
                   @"level" : @"write" }
            ]);
        });

        it(@"serialize location", ^{
            record[@"location"] = [[CLLocation alloc] initWithLatitude:1 longitude:2];

            NSDictionary *dictionary = [serializer dictionaryWithRecord:record];
            expect(dictionary[@"location"]).to.equal(@{
                @"$type" : @"geo",
                @"$lng" : @2,
                @"$lat" : @1,
            });
        });

        it(@"serialize sequence", ^{
            record[@"seq"] = [SKYSequence sequence];

            NSDictionary *dictionary = [serializer dictionaryWithRecord:record];
            expect(dictionary[@"seq"]).to.equal(@{
                @"$type" : @"seq",
            });
        });

        it(@"serialize transient fields (enabled)", ^{
            record.transient[@"hello"] = @"world";

            serializer.serializeTransientDictionary = YES;
            NSDictionary *dictionary = [serializer dictionaryWithRecord:record];
            expect(dictionary[@"_transient"]).to.equal(@{ @"hello" : @"world" });
        });

        it(@"serialize transient fields (disabled)", ^{
            record.transient[@"hello"] = @"world";

            NSDictionary *dictionary = [serializer dictionaryWithRecord:record];
            expect(dictionary[@"_transient"]).to.beNil();
        });

        it(@"serialize metadata", ^{
            record.creationDate = [NSDate dateWithTimeIntervalSinceReferenceDate:0];
            record.creatorUserRecordID = @"creator_id";
            record.modificationDate = [NSDate dateWithTimeIntervalSinceReferenceDate:1];
            record.lastModifiedUserRecordID = @"modifier_id";
            record.ownerUserRecordID = @"owner_id";

            NSDictionary *dictionary = [serializer dictionaryWithRecord:record];
            expect([SKYDataSerialization
                       dateFromString:dictionary[SKYRecordSerializationRecordCreatedAtKey]])
                .to.equal(record.creationDate);
            expect(dictionary[SKYRecordSerializationRecordCreatorIDKey]).to.equal(@"creator_id");
            expect([SKYDataSerialization
                       dateFromString:dictionary[SKYRecordSerializationRecordUpdatedAtKey]])
                .to.equal(record.modificationDate);
            expect(dictionary[SKYRecordSerializationRecordUpdaterIDKey]).to.equal(@"modifier_id");
            expect(dictionary[SKYRecordSerializationRecordOwnerIDKey]).to.equal(@"owner_id");
        });
    });

SpecEnd
