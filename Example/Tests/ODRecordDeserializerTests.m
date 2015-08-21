//
//  ODRecordDeserializerTests.m
//  ODKit
//
//  Created by Patrick Cheung on 26/2/15.
//  Copyright (c) 2015 Kwok-kuen Cheung. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

#import <ODKit/ODKit.h>

SpecBegin(ODRecordDeserializer)

describe(@"deserialize", ^{
    __block ODRecordDeserializer *deserializer = nil;
    __block NSDictionary *basicPayload = nil;
    
    beforeEach(^{
        deserializer = [ODRecordDeserializer deserializer];
        basicPayload = @{
                         ODRecordSerializationRecordTypeKey: @"record",
                         ODRecordSerializationRecordIDKey: @"book/book1",
                         };
    });
    
    it(@"init", ^{
        ODRecordDeserializer *deserializer = [ODRecordDeserializer deserializer];
        expect([deserializer class]).to.beSubclassOf([ODRecordDeserializer class]);
    });

    it(@"deserialize empty record", ^{
        NSDictionary *data = [basicPayload copy];
        ODRecord *record = [deserializer recordWithDictionary:data];
        expect([record class]).to.beSubclassOf([ODRecord class]);
        expect(record.recordID.recordName).to.equal(@"book1");
        expect(record.recordType).to.equal(@"book");
    });
    
    it(@"deserialize meta data", ^{
        NSMutableDictionary* data = [basicPayload mutableCopy];
        data[ODRecordSerializationRecordOwnerIDKey] = @"ownerUserID";

        ODRecord *record = [deserializer recordWithDictionary:data];
        expect(record.creatorUserRecordID.username).to.equal(@"ownerUserID");
    });

    it(@"deserialize null access control", ^{
        NSMutableDictionary* data = [basicPayload mutableCopy];
        data[@"_access"] = [NSNull null];

        ODRecord *record = [deserializer recordWithDictionary:data];
        expect(record.accessControl).notTo.beNil();
        expect(record.accessControl.public).to.equal(YES);
    });

    it(@"deserialize access control list", ^{
        NSMutableDictionary* data = [basicPayload mutableCopy];
        data[@"_access"] = @[
                             @{@"relation": @"friend", @"level": @"read"},
                             ];

        ODRecord *record = [deserializer recordWithDictionary:data];
        expect(record.accessControl).notTo.beNil();
        expect(record.accessControl.public).to.equal(NO);
    });

    it(@"deserialize string", ^{
        NSString *bookTitle = @"The tale of two cities";
        NSMutableDictionary *data = [basicPayload mutableCopy];
        data[@"title"] = bookTitle;
        ODRecord *record = [deserializer recordWithDictionary:data];
        expect(record[@"title"]).to.equal(bookTitle);
    });

    it(@"deserialize asset", ^{
        NSMutableDictionary *data = [basicPayload mutableCopy];
        data[@"asset"] = @{
                           @"$type": @"asset",
                           @"$name": @"some-asset",
                           @"$url": @"http://cit.test/files/some-asset",
                           };
        ODRecord *record = [deserializer recordWithDictionary:data];
        ODAsset *asset = record[@"asset"];
        expect(asset.name).to.equal(@"some-asset");
        expect(asset.url).to.equal([NSURL URLWithString:@"http://cit.test/files/some-asset"]);
    });

    it(@"deserialize reference", ^{
        NSMutableDictionary *data = [basicPayload mutableCopy];
        data[@"author"] = @{
                            ODDataSerializationCustomTypeKey: ODDataSerializationReferenceType,
                            @"$id": @"author/author1",
                            };
        ODRecord *record = [deserializer recordWithDictionary:data];
        ODReference *authorRef = record[@"author"];
        expect([authorRef class]).to.beSubclassOf([ODReference class]);
        expect(authorRef.recordID.recordName).to.equal(@"author1");
        expect(authorRef.recordID.recordType).to.equal(@"author");
    });
    
    it(@"deserialize date", ^{
        NSMutableDictionary *data = [basicPayload mutableCopy];
        data[@"published"] = @{
                               ODDataSerializationCustomTypeKey: ODDataSerializationDateType,
                               @"$date": @"2001-01-01T08:00:00+08:00",
                               };
        ODRecord *record = [deserializer recordWithDictionary:data];
        NSDate *publishDate = record[@"published"];
        expect([publishDate class]).to.beSubclassOf([NSDate class]);
        expect(publishDate).to.equal([NSDate dateWithTimeIntervalSinceReferenceDate:0]);
    });
    
    it(@"deserialize array", ^{
        NSMutableDictionary *data = [basicPayload mutableCopy];
        NSArray *topics = [NSArray arrayWithObjects:@"fiction", @"classic", nil];
        data[@"topics"] = topics;
        ODRecord *record = [deserializer recordWithDictionary:data];
        expect(record[@"topics"]).to.equal(topics);
    });
    
    it(@"deserialize location", ^{
        NSMutableDictionary *data = [basicPayload mutableCopy];
        data[@"location"] = @{
                              @"$type": @"geo",
                              @"$lng": @2,
                              @"$lat": @1,
                              };
        ODRecord *record = [deserializer recordWithDictionary:data];
        expect([record[@"location"] coordinate]).to.equal([[[CLLocation alloc] initWithLatitude:1 longitude:2] coordinate]);
        
    });
    
    it(@"deserialize transient fields", ^{
        NSMutableDictionary *data = [basicPayload mutableCopy];
        data[@"_transient"] = @{ @"hello": @"world" };
        ODRecord *record = [deserializer recordWithDictionary:data];
        expect(record.transient).to.equal(@{@"hello": @"world"});
    });
});

SpecEnd

