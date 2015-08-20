//
//  ODRecordSerializerTests.m
//  ODKit
//
//  Created by Patrick Cheung on 26/2/15.
//  Copyright (c) 2015 Kwok-kuen Cheung. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <ODKit/ODKit.h>

#import "ODAccessControl_Private.h"
#import "ODAccessControlEntry.h"
#import "ODAsset_Private.h"
#import "ODRecord_Private.h"

SpecBegin(ODRecordSerializer)

describe(@"serialize", ^{
    __block ODRecordSerializer *serializer = nil;
    __block ODRecord *record = nil;
    __block NSDateFormatter *dateFormatter = nil;
    
    beforeEach(^{
        serializer = [ODRecordSerializer serializer];
        record = [[ODRecord alloc] initWithRecordID:[[ODRecordID alloc] initWithRecordType:@"book" name:@"book1"] data:nil];
        
        dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZZZZZ"];
    });
    
    it(@"init", ^{
        ODRecordSerializer *serializer = [ODRecordSerializer serializer];
        expect([serializer class]).to.beSubclassOf([ODRecordSerializer class]);
    });
    
    it(@"serialize empty record", ^{
        NSDictionary *dictionary = [serializer dictionaryWithRecord:record];
        expect([dictionary class]).to.beSubclassOf([NSDictionary class]);
        expect(dictionary[ODRecordSerializationRecordTypeKey]).to.equal(@"record");
        expect(dictionary[ODRecordSerializationRecordIDKey]).to.equal(@"book/book1");
    });
    
    it(@"serialize string", ^{
        NSString *bookTitle = @"The tale of two cities";
        [record setObject:bookTitle forKey:@"title"];
        NSDictionary *dictionary = [serializer dictionaryWithRecord:record];
        expect(dictionary[@"title"]).to.equal(bookTitle);
    });

    it(@"serialize asset", ^{
        ODAsset *asset = [ODAsset assetWithName:@"asset-name" url:[NSURL URLWithString:@"http://ourd.test/files/asset-name"]];
        [record setObject:asset forKey:@"asset"];
        NSDictionary *dictionary = [serializer dictionaryWithRecord:record];
        expect(dictionary[@"asset"]).to.equal(@{
                                                @"$type": @"asset",
                                                @"$name": @"asset-name",
                                                });
    });

    it(@"serialize reference", ^{
        [record setObject:[[ODReference alloc] initWithRecordID:[[ODRecordID alloc] initWithRecordType:@"author" name:@"author1"]]
                   forKey:@"author"];
        NSDictionary *dictionary = [serializer dictionaryWithRecord:record];
        NSDictionary *authorRef = dictionary[@"author"];
        expect([authorRef class]).to.beSubclassOf([NSDictionary class]);
        expect(authorRef[ODDataSerializationCustomTypeKey]).to.equal(ODDataSerializationReferenceType);
        expect(authorRef[@"$id"]).to.equal(@"author/author1");
    });
    
    it(@"serialize date", ^{
        [record setObject:[NSDate dateWithTimeIntervalSinceReferenceDate:0]
                   forKey:@"published"];
        NSDictionary *dictionary = [serializer dictionaryWithRecord:record];
        NSDictionary *publishDate = dictionary[@"published"];
        expect([publishDate class]).to.beSubclassOf([NSDictionary class]);
        NSLog(@"%@", publishDate);
        expect(publishDate[ODDataSerializationCustomTypeKey]).to.equal(ODDataSerializationDateType);
        
        expect([dateFormatter dateFromString:publishDate[@"$date"]]).to.equal([NSDate dateWithTimeIntervalSinceReferenceDate:0]);
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
        record.accessControl = [ODAccessControl publicReadWriteAccessControl];

        NSDictionary *dictionary = [serializer dictionaryWithRecord:record];
        expect(dictionary[@"_access"]).to.equal([NSNull null]);
    });

    it(@"serialize empty access control", ^{
        record.accessControl = [ODAccessControl accessControlWithEntries:nil];

        NSDictionary *dictionary = [serializer dictionaryWithRecord:record];
        expect(dictionary[@"_access"]).to.equal(@[]);
    });

    it(@"serialize access control", ^{
        ODAccessControlEntry *entry = [ODAccessControlEntry writeEntryForRelation:[ODRelation relationFollow]];
        record.accessControl = [ODAccessControl accessControlWithEntries:@[entry]];

        NSDictionary *dictionary = [serializer dictionaryWithRecord:record];
        expect(dictionary[@"_access"]).to.equal(@[@{@"relation": @"follow", @"level": @"write"}]);
    });

    it(@"serialize location", ^{
        record[@"location"] = [[CLLocation alloc] initWithLatitude:1 longitude:2];

        NSDictionary *dictionary = [serializer dictionaryWithRecord:record];
        expect(dictionary[@"location"]).to.equal(@{
                                                   @"$type": @"geo",
                                                   @"$lng": @2,
                                                   @"$lat": @1,
                                                   });
    });
    
    it(@"serialize transient fields (enabled)", ^{
        record.transient[@"hello"] = @"world";
        
        serializer.serializeTransientDictionary = YES;
        NSDictionary *dictionary = [serializer dictionaryWithRecord:record];
        expect(dictionary[@"_transient"]).to.equal(@{@"hello": @"world"});
    });
    
    it(@"serialize transient fields (disabled)", ^{
        record.transient[@"hello"] = @"world";
        
        NSDictionary *dictionary = [serializer dictionaryWithRecord:record];
        expect(dictionary[@"_transient"]).to.beNil();
    });
});

SpecEnd