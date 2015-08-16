//
//  ODQueryDeserializerTests.m
//  ODKit
//
//  Created by Kenji Pa on 23/4/15.
//  Copyright (c) 2015 Kwok-kuen Cheung. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>
#import <UIKit/UIKit.h>
#import <ODKit/ODKit.h>

SpecBegin(ODQueryDeserializer)

describe(@"deserialize query", ^{
    __block ODQueryDeserializer *deserializer = nil;
    __block ODQuery *query = nil;

    beforeEach(^{
        deserializer = [ODQueryDeserializer deserializer];
        query = [[ODQuery alloc] initWithRecordType:@"recordType"
                                          predicate:nil];
    });

    it(@"init", ^{
        ODQueryDeserializer *deserializer = [ODQueryDeserializer deserializer];
        expect([deserializer class]).to.beSubclassOf([ODQueryDeserializer class]);
    });

    it(@"deserialize eager load path", ^{
        NSDictionary *queryDict = @{
                                    @"record_type": @"recordType",
                                    @"eager": @[
                                            @{@"$type": @"keypath", @"$val": @"name"},
                                            ]
                                    };

        ODQuery *query = [deserializer queryWithDictionary:queryDict];
        expect(query.recordType).to.equal(@"recordType");
        expect(query.eagerLoadKeyPath).to.equal(@"name");
        expect(query.predicate).to.equal(nil);
    });

    it(@"deserialize predicate", ^{
        NSDictionary *queryDict = @{
                                    @"record_type": @"recordType",
                                    @"predicate": @[@"eq", @{@"$type": @"keypath", @"$val": @"name"}, @"John"],
                                    };

        ODQuery *query = [deserializer queryWithDictionary:queryDict];
        expect(query.recordType).to.equal(@"recordType");
        expect(query.predicate).to.equal([NSPredicate predicateWithFormat:@"name = %@", @"John"]);
    });

    it(@"deserialize sort", ^{
        NSDictionary *queryDict = @{
                                    @"record_type": @"recordType",
                                    @"sort": @[
                                            @[@{@"$type": @"keypath", @"$val": @"name"}, @"asc"]
                                            ],
                                    };

        ODQuery *query = [deserializer queryWithDictionary:queryDict];
        expect(query.recordType).to.equal(@"recordType");
        expect(query.sortDescriptors).to.equal(@[
                                                 [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES],
                                                 ]);
    });
});

describe(@"deserialize predicate", ^{
    __block ODQueryDeserializer *deserializer = nil;

    beforeEach(^{
        deserializer = [ODQueryDeserializer deserializer];
    });

    it(@"equal string", ^{
        NSArray *predicateArray = @[@"eq", @{@"$type": @"keypath", @"$val": @"name"}, @"Peter"];

        NSPredicate *predicate = [deserializer predicateWithArray:predicateArray];
        expect(predicate).to.equal([NSPredicate predicateWithFormat:@"name = %@", @"Peter"]);
    });

    it(@"equal integer", ^{
        NSArray *predicateArray = @[@"eq", @{@"$type": @"keypath", @"$val": @"name"}, @12];

        NSPredicate *predicate = [deserializer predicateWithArray:predicateArray];
        expect(predicate).to.equal([NSPredicate predicateWithFormat:@"name = %@", @12]);
    });

    it(@"equal float", ^{
        NSArray *predicateArray = @[@"eq", @{@"$type": @"keypath", @"$val": @"name"}, @12.1];

        NSPredicate *predicate = [deserializer predicateWithArray:predicateArray];
        expect(predicate).to.equal([NSPredicate predicateWithFormat:@"name = %@", @12.1]);
    });

    it(@"equal date", ^{
        NSArray *predicateArray = @[@"eq", @{@"$type": @"keypath", @"$val": @"dob"}, @{@"$type": @"date", @"$date": @"2015-02-02T01:43:19+00:00"}];

        NSPredicate *predicate = [deserializer predicateWithArray:predicateArray];
        expect(predicate).to.equal([NSPredicate predicateWithFormat:@"dob = %@", [NSDate dateWithTimeIntervalSince1970:1422841399]]);
    });

    it(@"equal reference", ^{
        NSArray *predicateArray = @[@"eq", @{@"$type": @"keypath", @"$val": @"city"}, @{@"$type": @"ref", @"$id": @"city/hongkong"}];

        NSPredicate *predicate = [deserializer predicateWithArray:predicateArray];
        ODReference *reference = [[ODReference alloc] initWithRecordID:[[ODRecordID alloc] initWithRecordType:@"city" name:@"hongkong"]];
        expect(predicate).to.equal([NSPredicate predicateWithFormat:@"city = %@", reference]);
    });

    it(@"greater than integer", ^{
        NSArray *predicateArray = @[@"gt", @{@"$type": @"keypath", @"$val": @"name"}, @12];

        NSPredicate *predicate = [deserializer predicateWithArray:predicateArray];
        expect(predicate).to.equal([NSPredicate predicateWithFormat:@"name > %@", @12]);
    });

    it(@"greater than or equal to integer", ^{
        NSArray *predicateArray = @[@"gte", @{@"$type": @"keypath", @"$val": @"name"}, @12];

        NSPredicate *predicate = [deserializer predicateWithArray:predicateArray];
        expect(predicate).to.equal([NSPredicate predicateWithFormat:@"name >= %@", @12]);
    });

    it(@"less than integer", ^{
        NSArray *predicateArray = @[@"lt", @{@"$type": @"keypath", @"$val": @"name"}, @12];

        NSPredicate *predicate = [deserializer predicateWithArray:predicateArray];
        expect(predicate).to.equal([NSPredicate predicateWithFormat:@"name < %@", @12]);
    });

    it(@"less than or equal to integer", ^{
        NSArray *predicateArray = @[@"lte", @{@"$type": @"keypath", @"$val": @"name"}, @12];

        NSPredicate *predicate = [deserializer predicateWithArray:predicateArray];
        expect(predicate).to.equal([NSPredicate predicateWithFormat:@"name <= %@", @12]);
    });

    it(@"not equal integer", ^{
        NSArray *predicateArray = @[@"neq", @{@"$type": @"keypath", @"$val": @"name"}, @12];

        NSPredicate *predicate = [deserializer predicateWithArray:predicateArray];
        expect(predicate).to.equal([NSPredicate predicateWithFormat:@"name <> %@", @12]);
    });

    it(@"func distance", ^{
        NSArray *predicateArray = @[@"lt",
                                    @[@"func",
                                      @"distance",
                                      @{@"$type": @"keypath", @"$val": @"location"},
                                      @{@"$type": @"geo", @"$lng": @2, @"$lat": @1}
                                      ],
                                    @3,
                                    ];

        // CLLocation doesn't implement isEqualTo, checking it manually here

        id predicate = [deserializer predicateWithArray:predicateArray];
        expect(predicate).to.beInstanceOf([NSComparisonPredicate class]);

        NSExpression *leftExpression = [predicate leftExpression];
        expect(leftExpression.function).to.equal(@"distanceToLocation:fromLocation:");

        expect(leftExpression.arguments.count).to.equal(2);
        expect(leftExpression.arguments[0]).to.equal([NSExpression expressionForKeyPath:@"location"]);
        CLLocation *loc = [leftExpression.arguments[1] constantValue];
        expect(loc.coordinate).to.equal(CLLocationCoordinate2DMake(1, 2));

        expect([predicate rightExpression]).to.equal([NSExpression expressionForConstantValue:@3]);
    });

    it(@"and", ^{
        NSArray *predicateArray = @[@"and", @[@"eq", @{@"$type": @"keypath", @"$val": @"name"}, @"Peter"], @[@"gte", @{@"$type": @"keypath", @"$val": @"age"}, @12]];

        NSPredicate *predicate = [deserializer predicateWithArray:predicateArray];
        expect(predicate).to.equal([NSPredicate predicateWithFormat:@"name = %@ && age >= %d", @"Peter", 12]);
    });

    it(@"double and", ^{
        NSArray *predicateArray = @[@"and", @[@"eq", @{@"$type": @"keypath", @"$val": @"name"}, @"Peter"], @[@"gte", @{@"$type": @"keypath", @"$val": @"age"}, @12], @[@"neq", @{@"$type": @"keypath", @"$val": @"interest"}, @"reading"]];

        NSPredicate *predicate = [deserializer predicateWithArray:predicateArray];
        expect(predicate).to.equal([NSPredicate predicateWithFormat:@"name = %@ && age >= %d && interest <> %@", @"Peter", 12, @"reading"]);
    });

    it(@"or", ^{
        NSArray *predicateArray = @[@"or", @[@"eq", @{@"$type": @"keypath", @"$val": @"name"}, @"Peter"], @[@"gte", @{@"$type": @"keypath", @"$val": @"age"}, @12]];

        NSPredicate *predicate = [deserializer predicateWithArray:predicateArray];
        expect(predicate).to.equal([NSPredicate predicateWithFormat:@"name = %@ || age >= %d", @"Peter", 12]);
    });

    it(@"not", ^{
        NSArray *predicateArray = @[@"not", @[@"eq", @{@"$type": @"keypath", @"$val": @"name"}, @"Peter"]];

        NSPredicate *predicate = [deserializer predicateWithArray:predicateArray];
        expect(predicate).to.equal([NSPredicate predicateWithFormat:@"not (name = %@)", @"Peter"]);
    });
});

describe(@"serialize sort descriptors", ^{
    __block ODQueryDeserializer *deserializer = nil;

    beforeEach(^{
        deserializer = [ODQueryDeserializer deserializer];
    });

    it(@"nil", ^{
        NSArray *sortDescriptors = [deserializer sortDescriptorsWithArray:nil];
        expect(sortDescriptors).to.equal(@[]);
    });

    it(@"empty", ^{
        NSArray *sortDescriptors = [deserializer sortDescriptorsWithArray:@[]];
        expect(sortDescriptors).to.equal(@[]);
    });

    it(@"sort asc", ^{
        NSArray *sdArray = @[@[@{@"$type": @"keypath", @"$val": @"name"}, @"asc"]];

        NSArray *sortDescriptors = [deserializer sortDescriptorsWithArray:sdArray];
        expect(sortDescriptors).to.equal(@[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]]);
    });

    it(@"sort desc", ^{
        NSArray *sdArray = @[@[@{@"$type": @"keypath", @"$val": @"name"}, @"desc"]];

        NSArray *sortDescriptors = [deserializer sortDescriptorsWithArray:sdArray];
        expect(sortDescriptors).to.equal(@[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:NO]]);
    });

    it(@"sort multiple", ^{
        NSArray *sdArray = @[
                             @[@{@"$type": @"keypath", @"$val": @"name"}, @"desc"],
                             @[@{@"$type": @"keypath", @"$val": @"age"}, @"asc"],
                             ];

        NSArray *sortDescriptors = [deserializer sortDescriptorsWithArray:sdArray];
        expect(sortDescriptors).to.equal(@[
                                           [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:NO],
                                           [NSSortDescriptor sortDescriptorWithKey:@"age" ascending:YES],
                                           ]);
    });
});

SpecEnd
