//
//  ODQuerySerializerTests.m
//  ODKit
//
//  Created by Patrick Cheung on 14/3/15.
//  Copyright (c) 2015 Kwok-kuen Cheung. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ODKit/ODKit.h>

SpecBegin(ODQuerySerializer)

describe(@"deserialize", ^{
    __block ODQuerySerializer *serializer = nil;
    __block NSDictionary *basicPayload = nil;
    __block NSDateFormatter *dateFormatter = nil;
    
    beforeEach(^{
        serializer = [ODQuerySerializer serializer];
        basicPayload = @{
                         ODRecordSerializationRecordTypeKey: @"book",
                         ODRecordSerializationRecordIDKey: @"book1",
                         };
        dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZZZZZ"];
    });
    
    it(@"init", ^{
        ODQuerySerializer *serializer = [ODQuerySerializer serializer];
        expect([serializer class]).to.beSubclassOf([ODQuerySerializer class]);
    });
    
    it(@"lhs key path", ^{
        NSArray *result = [serializer serializeWithPredicate:
                           [NSPredicate predicateWithFormat:@"name = %@", @"Peter"]];
        expect([result class]).to.beSubclassOf([NSArray class]);
        expect(result).to.haveCountOf(3);
        expect(result[0]).to.equal(@"eq");
        expect([result[1] class]).to.beSubclassOf([NSDictionary class]);
        expect(result[1][@"$type"]).to.equal(@"keypath");
        expect(result[1][@"$val"]).to.equal(@"name");
        expect(result[2]).to.equal(@"Peter");
    });
    
    it(@"equal string", ^{
        NSArray *result = [serializer serializeWithPredicate:
                           [NSPredicate predicateWithFormat:@"name = %@", @"Peter"]];
        expect([result class]).to.beSubclassOf([NSArray class]);
        expect(result[0]).to.equal(@"eq");
        expect(result[2]).to.equal(@"Peter");
    });
    
    it(@"equal integer", ^{
        NSArray *result = [serializer serializeWithPredicate:
                           [NSPredicate predicateWithFormat:@"name = %d", 12]];
        expect([result class]).to.beSubclassOf([NSArray class]);
        expect(result[0]).to.equal(@"eq");
        expect(result[2]).to.equal(12);
    });
    
    it(@"equal number", ^{
        NSArray *result = [serializer serializeWithPredicate:
                           [NSPredicate predicateWithFormat:@"name = %@", @12]];
        expect([result class]).to.beSubclassOf([NSArray class]);
        expect(result[0]).to.equal(@"eq");
        expect(result[2]).to.equal(12);
    });
    
    it(@"equal date", ^{
        NSDate *dob = [NSDate dateWithTimeIntervalSinceReferenceDate:0];
        NSArray *result = [serializer serializeWithPredicate:
                           [NSPredicate predicateWithFormat:@"dob = %@", dob]];
        expect([result class]).to.beSubclassOf([NSArray class]);
        expect(result[0]).to.equal(@"eq");
        expect(result[2][@"$type"]).to.equal(@"date");
        expect([dateFormatter dateFromString:result[2][@"$date"]]).to.equal(dob);
    });
    
    it(@"greater than integer", ^{
        NSArray *result = [serializer serializeWithPredicate:
                           [NSPredicate predicateWithFormat:@"name > %d", 12]];
        expect([result class]).to.beSubclassOf([NSArray class]);
        expect(result[0]).to.equal(@"gt");
        expect(result[2]).to.equal(12);
    });
    
    it(@"greater than or equal integer", ^{
        NSArray *result = [serializer serializeWithPredicate:
                           [NSPredicate predicateWithFormat:@"name >= %d", 12]];
        expect([result class]).to.beSubclassOf([NSArray class]);
        expect(result[0]).to.equal(@"gte");
        expect(result[2]).to.equal(12);
    });
    
    it(@"less than integer", ^{
        NSArray *result = [serializer serializeWithPredicate:
                           [NSPredicate predicateWithFormat:@"name < %d", 12]];
        expect([result class]).to.beSubclassOf([NSArray class]);
        expect(result[0]).to.equal(@"lt");
        expect(result[2]).to.equal(12);
    });
    
    it(@"less than or equal integer", ^{
        NSArray *result = [serializer serializeWithPredicate:
                           [NSPredicate predicateWithFormat:@"name <= %d", 12]];
        expect([result class]).to.beSubclassOf([NSArray class]);
        expect(result[0]).to.equal(@"lte");
        expect(result[2]).to.equal(12);
    });
    
    it(@"not equal integer", ^{
        NSArray *result = [serializer serializeWithPredicate:
                           [NSPredicate predicateWithFormat:@"name <> %d", 12]];
        expect([result class]).to.beSubclassOf([NSArray class]);
        expect(result[0]).to.equal(@"neq");
        expect(result[2]).to.equal(12);
    });
    
    it(@"and", ^{
        NSArray *result = [serializer serializeWithPredicate:
                           [NSPredicate predicateWithFormat:@"name = %@ && age >= %d", @"Peter", 12]];
        expect([result class]).to.beSubclassOf([NSArray class]);
        expect(result).to.haveCountOf(3);
        expect(result[0]).to.equal(@"and");
        expect([result[1] class]).to.beSubclassOf([NSArray class]);
        expect(result[1][0]).to.equal(@"eq");
        expect([result[2] class]).to.beSubclassOf([NSArray class]);
        expect(result[2][0]).to.equal(@"gte");
    });
    
    it(@"double and", ^{
        NSArray *result = [serializer serializeWithPredicate:
                           [NSPredicate predicateWithFormat:@"name = %@ && age >= %d && interest <> %@", @"Peter", 12, @"reading"]];
        expect([result class]).to.beSubclassOf([NSArray class]);
        expect(result).to.haveCountOf(4);
        expect(result[0]).to.equal(@"and");
        expect([result[1] class]).to.beSubclassOf([NSArray class]);
        expect(result[3][0]).to.equal(@"neq");
    });
    
    it(@"or", ^{
        NSArray *result = [serializer serializeWithPredicate:
                           [NSPredicate predicateWithFormat:@"name = %@ || age >= %d", @"Peter", 12]];
        expect([result class]).to.beSubclassOf([NSArray class]);
        expect(result).to.haveCountOf(3);
        expect(result[0]).to.equal(@"or");
        expect([result[1] class]).to.beSubclassOf([NSArray class]);
        expect(result[1][0]).to.equal(@"eq");
        expect([result[2] class]).to.beSubclassOf([NSArray class]);
        expect(result[2][0]).to.equal(@"gte");
    });
    
    it(@"not", ^{
        NSArray *result = [serializer serializeWithPredicate:
                           [NSPredicate predicateWithFormat:@"not (name = %@)", @"Peter"]];
        expect([result class]).to.beSubclassOf([NSArray class]);
        expect(result).to.haveCountOf(2);
        expect(result[0]).to.equal(@"not");
        expect([result[1] class]).to.beSubclassOf([NSArray class]);
        expect(result[1][0]).to.equal(@"eq");
    });
});

SpecEnd

