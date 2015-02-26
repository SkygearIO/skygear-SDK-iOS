//
//  ODRecordSerializerTests.m
//  ODKit
//
//  Created by Patrick Cheung on 26/2/15.
//  Copyright (c) 2015 Kwok-kuen Cheung. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ODKit/ODKit.h>

SpecBegin(ODRecordSerializer)

describe(@"serialize", ^{
    __block ODRecordSerializer *serializer = nil;
    __block ODRecord *record = nil;
    
    beforeEach(^{
        serializer = [ODRecordSerializer serializer];
        record = [[ODRecord alloc] initWithRecordType:@"book"
                                             recordID:[[ODRecordID alloc] initWithRecordName:@"book1"]];
    });
    
    it(@"init", ^{
        ODRecordSerializer *serializer = [ODRecordSerializer serializer];
        expect([serializer class]).to.beSubclassOf([ODRecordSerializer class]);
    });
    
    it(@"serialize empty record", ^{
        NSDictionary *dictionary = [serializer dictionaryWithRecord:record];
        expect([dictionary class]).to.beSubclassOf([NSDictionary class]);
        expect(dictionary[ODRecordSerializationRecordTypeKey]).to.equal(@"book");
        expect(dictionary[ODRecordSerializationRecordIDKey]).to.equal(@"book1");
    });
    
    it(@"serialize string", ^{
        NSString *bookTitle = @"The tale of two cities";
        [record setObject:bookTitle forKey:@"title"];
        NSDictionary *dictionary = [serializer dictionaryWithRecord:record];
        expect(dictionary[@"title"]).to.equal(bookTitle);
    });
    
    it(@"serialize reference", ^{
        [record setObject:[[ODReference alloc] initWithRecordID:[[ODRecordID alloc] initWithRecordName:@"author1"]]
                   forKey:@"author"];
        NSDictionary *dictionary = [serializer dictionaryWithRecord:record];
        NSDictionary *authorRef = dictionary[@"author"];
        expect([authorRef class]).to.beSubclassOf([NSDictionary class]);
        expect(authorRef[ODRecordSerializationCustomTypeKey]).to.equal(ODRecordSerializationReferenceType);
        expect(authorRef[@"$id"]).to.equal(@"author1");
    });
    
    it(@"serialize date", ^{
        [record setObject:[NSDate dateWithTimeIntervalSinceReferenceDate:0]
                   forKey:@"published"];
        NSDictionary *dictionary = [serializer dictionaryWithRecord:record];
        NSDictionary *publishDate = dictionary[@"published"];
        expect([publishDate class]).to.beSubclassOf([NSDictionary class]);
        NSLog(@"%@", publishDate);
        expect(publishDate[ODRecordSerializationCustomTypeKey]).to.equal(ODRecordSerializationDateType);
        expect(publishDate[@"$date"]).to.equal(@"2001-01-01T08:00:00+08:00");
    });
    
    it(@"serialize array", ^{
        NSArray *topics = [NSArray arrayWithObjects:@"fiction", @"classic", nil];
        [record setObject:topics forKey:@"topics"];
        NSDictionary *dictionary = [serializer dictionaryWithRecord:record];
        NSArray *serializedTopics = dictionary[@"topics"];
        expect([serializedTopics class]).to.beSubclassOf([NSArray class]);
        expect(serializedTopics).to.equal(topics);
    });

});

SpecEnd