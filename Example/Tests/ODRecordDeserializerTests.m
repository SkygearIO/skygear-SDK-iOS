//
//  ODRecordDeserializerTests.m
//  ODKit
//
//  Created by Patrick Cheung on 26/2/15.
//  Copyright (c) 2015 Kwok-kuen Cheung. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ODKit/ODKit.h>

SpecBegin(ODRecordDeserializer)

describe(@"deserialize", ^{
    __block ODRecordDeserializer *deserializer = nil;
    __block NSDictionary *basicPayload = nil;
    
    beforeEach(^{
        deserializer = [ODRecordDeserializer deserializer];
        basicPayload = @{
                         ODRecordSerializationRecordTypeKey: @"book",
                         ODRecordSerializationRecordIDKey: @"book1",
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
    
    it(@"deserialize string", ^{
        NSString *bookTitle = @"The tale of two cities";
        NSMutableDictionary *data = [basicPayload mutableCopy];
        data[@"title"] = bookTitle;
        ODRecord *record = [deserializer recordWithDictionary:data];
        expect(record[@"title"]).to.equal(bookTitle);
    });
    
    it(@"serialize reference", ^{
        NSMutableDictionary *data = [basicPayload mutableCopy];
        data[@"author"] = @{
                            ODDataSerializationCustomTypeKey: ODDataSerializationReferenceType,
                            @"$id": @"author1",
                            @"$class": @"author",
                            };
        ODRecord *record = [deserializer recordWithDictionary:data];
        ODReference *authorRef = record[@"author"];
        expect([authorRef class]).to.beSubclassOf([ODReference class]);
        expect(authorRef.recordID.recordName).to.equal(@"author1");
    });
    
    it(@"serialize date", ^{
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
    
    it(@"serialize array", ^{
        NSMutableDictionary *data = [basicPayload mutableCopy];
        NSArray *topics = [NSArray arrayWithObjects:@"fiction", @"classic", nil];
        data[@"topics"] = topics;
        ODRecord *record = [deserializer recordWithDictionary:data];
        expect(record[@"topics"]).to.equal(topics);
    });
    
});

SpecEnd

