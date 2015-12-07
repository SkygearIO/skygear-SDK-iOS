//
//  SKYRecordSerializerTests.m
//  SkyKit
//
//  Created by Patrick Cheung on 26/2/15.
//  Copyright (c) 2015 Kwok-kuen Cheung. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <SkyKit/SkyKit.h>

#import "SKYAccessControl_Private.h"
#import "SKYAccessControlEntry.h"
#import "SKYAsset_Private.h"
#import "SKYRecord_Private.h"

SpecBegin(SKYRecordSerializer)

    describe(@"serialize", ^{
        __block SKYRecordSerializer *serializer = nil;
        __block SKYRecord *record = nil;
        __block NSDateFormatter *dateFormatter = nil;

        beforeEach(^{
            serializer = [SKYRecordSerializer serializer];
            record = [[SKYRecord alloc]
                initWithRecordID:[[SKYRecordID alloc] initWithRecordType:@"book" name:@"book1"]
                            data:nil];

            dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZZZZZ"];
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
            expect(dictionary[@"asset"])
                .to.equal(@{
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

            expect([dateFormatter dateFromString:publishDate[@"$date"]])
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

        it(@"serialize public access control", ^{
            record.accessControl = [SKYAccessControl publicReadWriteAccessControl];

            NSDictionary *dictionary = [serializer dictionaryWithRecord:record];
            expect(dictionary[@"_access"]).to.equal([NSNull null]);
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
            expect(dictionary[@"_access"])
                .to.equal(@[
                    @{ @"relation" : @"follow",
                       @"level" : @"write" }
                ]);
        });

        it(@"serialize location", ^{
            record[@"location"] = [[CLLocation alloc] initWithLatitude:1 longitude:2];

            NSDictionary *dictionary = [serializer dictionaryWithRecord:record];
            expect(dictionary[@"location"])
                .to.equal(@{
                    @"$type" : @"geo",
                    @"$lng" : @2,
                    @"$lat" : @1,
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
    });

SpecEnd
