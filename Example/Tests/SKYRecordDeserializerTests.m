//
//  SKYRecordDeserializerTests.m
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

#import <SKYKit/SKYAccessControl_Private.h>
#import <SKYKit/SKYKit.h>

SpecBegin(SKYRecordDeserializer)

    describe(@"deserialize", ^{
        __block SKYRecordDeserializer *deserializer = nil;
        __block NSDictionary *basicPayload = nil;

        beforeEach(^{
            deserializer = [SKYRecordDeserializer deserializer];
            basicPayload = @{
                SKYRecordSerializationRecordTypeKey : @"record",
                SKYRecordSerializationRecordIDKey : @"book/book1",
            };
        });

        it(@"init", ^{
            SKYRecordDeserializer *deserializer = [SKYRecordDeserializer deserializer];
            expect([deserializer class]).to.beSubclassOf([SKYRecordDeserializer class]);
        });

        it(@"deserialize empty record", ^{
            NSDictionary *data = [basicPayload copy];
            SKYRecord *record = [deserializer recordWithDictionary:data];
            expect([record class]).to.beSubclassOf([SKYRecord class]);
            expect(record.recordID.recordName).to.equal(@"book1");
            expect(record.recordType).to.equal(@"book");
        });

        it(@"deserialize meta data", ^{
            NSMutableDictionary *data = [basicPayload mutableCopy];
            data[SKYRecordSerializationRecordOwnerIDKey] = @"ownerID";
            data[SKYRecordSerializationRecordCreatedAtKey] = @"2006-01-02T15:04:05.000000Z";
            data[SKYRecordSerializationRecordCreatorIDKey] = @"creatorID";
            data[SKYRecordSerializationRecordUpdatedAtKey] = @"2006-01-02T15:04:06.000000Z";
            data[SKYRecordSerializationRecordUpdaterIDKey] = @"updaterID";

            SKYRecord *record = [deserializer recordWithDictionary:data];
            expect(record.ownerUserRecordID).to.equal(@"ownerID");
            expect(record.creationDate).to.equal([NSDate dateWithTimeIntervalSince1970:1136214245]);
            expect(record.creatorUserRecordID).to.equal(@"creatorID");
            expect(record.modificationDate)
                .to.equal([NSDate dateWithTimeIntervalSince1970:1136214246]);
            expect(record.lastModifiedUserRecordID).to.equal(@"updaterID");
        });

        it(@"deserialize nil", ^{
            NSMutableDictionary *data = [basicPayload mutableCopy];
            data[@"nil"] = nil;

            SKYRecord *record = [deserializer recordWithDictionary:data];
            expect(record[@"nil"]).to.beNil();
        });

        it(@"deserialize NSNull", ^{
            NSMutableDictionary *data = [basicPayload mutableCopy];
            data[@"null"] = [NSNull null];

            SKYRecord *record = [deserializer recordWithDictionary:data];
            expect(record[@"null"]).to.beNil();
        });

        it(@"deserialize null access control", ^{
            NSMutableDictionary *data = [basicPayload mutableCopy];
            data[@"_access"] = [NSNull null];

            SKYRecord *record = [deserializer recordWithDictionary:data];
            expect(record.accessControl).to.beNil();
        });

        it(@"deserialize access control list", ^{
            NSMutableDictionary *data = [basicPayload mutableCopy];
            data[@"_access"] = @[
                @{ @"relation" : @"friend",
                   @"level" : @"read" },
            ];

            SKYRecord *record = [deserializer recordWithDictionary:data];
            expect(record.accessControl).notTo.beNil();
            expect(record.accessControl.entries).to.haveCountOf(1);
            expect(record.accessControl.entries[0].entryType)
                .to.equal(SKYAccessControlEntryTypeRelation);
            expect(record.accessControl.entries[0].accessLevel)
                .to.equal(SKYAccessControlEntryLevelRead);
            expect(record.accessControl.entries[0].relation.name).to.equal(@"friend");
        });

        it(@"deserialize string", ^{
            NSString *bookTitle = @"The tale of two cities";
            NSMutableDictionary *data = [basicPayload mutableCopy];
            data[@"title"] = bookTitle;
            SKYRecord *record = [deserializer recordWithDictionary:data];
            expect(record[@"title"]).to.equal(bookTitle);
        });

        it(@"deserialize asset", ^{
            NSMutableDictionary *data = [basicPayload mutableCopy];
            data[@"asset"] = @{
                @"$type" : @"asset",
                @"$name" : @"some-asset",
                @"$url" : @"http://cit.test/files/some-asset",
            };
            SKYRecord *record = [deserializer recordWithDictionary:data];
            SKYAsset *asset = record[@"asset"];
            expect(asset.name).to.equal(@"some-asset");
            expect(asset.url).to.equal([NSURL URLWithString:@"http://cit.test/files/some-asset"]);
        });

        it(@"deserialize reference", ^{
            NSMutableDictionary *data = [basicPayload mutableCopy];
            data[@"author"] = @{
                SKYDataSerializationCustomTypeKey : SKYDataSerializationReferenceType,
                @"$id" : @"author/author1",
            };
            SKYRecord *record = [deserializer recordWithDictionary:data];
            SKYReference *authorRef = record[@"author"];
            expect([authorRef class]).to.beSubclassOf([SKYReference class]);
            expect(authorRef.recordID.recordName).to.equal(@"author1");
            expect(authorRef.recordID.recordType).to.equal(@"author");
        });

        it(@"deserialize date in RFC3339Nano", ^{
            NSMutableDictionary *data = [basicPayload mutableCopy];
            data[@"published"] = @{
                SKYDataSerializationCustomTypeKey : SKYDataSerializationDateType,
                @"$date" : @"2001-01-01T00:00:00.000000Z",
            };
            SKYRecord *record = [deserializer recordWithDictionary:data];
            NSDate *publishDate = record[@"published"];
            expect([publishDate class]).to.beSubclassOf([NSDate class]);
            expect(publishDate).to.equal([NSDate dateWithTimeIntervalSinceReferenceDate:0]);
        });

        it(@"deserialize date in RFC3339", ^{
            NSMutableDictionary *data = [basicPayload mutableCopy];
            data[@"published"] = @{
                SKYDataSerializationCustomTypeKey : SKYDataSerializationDateType,
                @"$date" : @"2001-01-01T00:00:00Z",
            };
            SKYRecord *record = [deserializer recordWithDictionary:data];
            NSDate *publishDate = record[@"published"];
            expect([publishDate class]).to.beSubclassOf([NSDate class]);
            expect(publishDate).to.equal([NSDate dateWithTimeIntervalSinceReferenceDate:0]);
        });

        it(@"deserialize date with wrong format", ^{
            NSMutableDictionary *data = [basicPayload mutableCopy];
            data[@"published"] = @{
                SKYDataSerializationCustomTypeKey : SKYDataSerializationDateType,
                @"$date" : @"badformat",
            };
            SKYRecord *record = [deserializer recordWithDictionary:data];
            expect(record[@"published"]).to.beNil();
        });

        it(@"deserialize array", ^{
            NSMutableDictionary *data = [basicPayload mutableCopy];
            NSArray *topics = [NSArray arrayWithObjects:@"fiction", @"classic", nil];
            data[@"topics"] = topics;
            SKYRecord *record = [deserializer recordWithDictionary:data];
            expect(record[@"topics"]).to.equal(topics);
        });

        it(@"deserialize location", ^{
            NSMutableDictionary *data = [basicPayload mutableCopy];
            data[@"location"] = @{
                @"$type" : @"geo",
                @"$lng" : @2,
                @"$lat" : @1,
            };
            SKYRecord *record = [deserializer recordWithDictionary:data];
            expect([record[@"location"] coordinate])
                .to.equal([[[CLLocation alloc] initWithLatitude:1 longitude:2] coordinate]);

        });

        it(@"deserialize sequence", ^{
            NSMutableDictionary *data = [basicPayload mutableCopy];
            data[@"seq"] = @{
                @"$type" : @"seq",
            };
            SKYRecord *record = [deserializer recordWithDictionary:data];
            expect([record[@"seq"] class]).to.beSubclassOf([SKYSequence class]);

        });

        it(@"deserialize unknown value", ^{
            NSMutableDictionary *data = [basicPayload mutableCopy];
            data[@"money"] = @{
                @"$type" : @"unknown",
                @"$underlying_type" : @"money",
            };
            SKYRecord *record = [deserializer recordWithDictionary:data];
            expect([record[@"money"] class]).to.beSubclassOf([SKYUnknownValue class]);
            expect([(SKYUnknownValue *)record[@"money"] underlyingType]).to.equal(@"money");
        });

        it(@"deserialize unknown value with no underlying type", ^{
            NSMutableDictionary *data = [basicPayload mutableCopy];
            data[@"money"] = @{
                @"$type" : @"unknown",
            };
            SKYRecord *record = [deserializer recordWithDictionary:data];
            expect([record[@"money"] class]).to.beSubclassOf([SKYUnknownValue class]);
            expect([(SKYUnknownValue *)record[@"money"] underlyingType]).to.beNil();
        });

        it(@"deserialize transient fields", ^{
            NSMutableDictionary *data = [basicPayload mutableCopy];
            data[@"_transient"] = @{ @"hello" : @"world" };
            SKYRecord *record = [deserializer recordWithDictionary:data];
            expect(record.transient).to.equal(@{ @"hello" : @"world" });
        });
    });

SpecEnd
