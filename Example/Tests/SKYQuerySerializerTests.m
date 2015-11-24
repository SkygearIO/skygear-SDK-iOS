//
//  SKYQuerySerializerTests.m
//  SkyKit
//
//  Created by Patrick Cheung on 14/3/15.
//  Copyright (c) 2015 Kwok-kuen Cheung. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <SkyKit/SkyKit.h>

SpecBegin(SKYQuerySerializer)

    describe(@"serialize query", ^{
        __block SKYQuerySerializer *serializer = nil;
        __block SKYQuery *query = nil;

        beforeEach(^{
            serializer = [SKYQuerySerializer serializer];
            query = [[SKYQuery alloc] initWithRecordType:@"recordType" predicate:nil];
        });

        it(@"init", ^{
            SKYQuerySerializer *serializer = [SKYQuerySerializer serializer];
            expect([serializer class]).to.beSubclassOf([SKYQuerySerializer class]);
        });

        it(@"serialize nil", ^{
            NSDictionary *result = [serializer serializeWithQuery:nil];
            expect(result).to.equal(@{});
        });

        it(@"serialize transient", ^{
            query.transientIncludes = @{
                @"city" : [NSExpression expressionForKeyPath:@"city"],
            };

            NSDictionary *result = [serializer serializeWithQuery:query];
            expect(result).to.equal(@{
                @"record_type" : @"recordType",
                @"include" : @{@"city" : @{@"$type" : @"keypath", @"$val" : @"city"}},
            });
        });

        it(@"serialize sort", ^{
            query.sortDescriptors =
                @[ [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES] ];

            NSDictionary *result = [serializer serializeWithQuery:query];
            expect(result).to.equal(@{
                @"record_type" : @"recordType",
                @"sort" : @[ @[ @{@"$type" : @"keypath", @"$val" : @"name"}, @"asc" ] ],
            });
        });

        it(@"serialize limit, offset and overallCount", ^{
            query.limit = 30;
            query.offset = 5;
            query.overallCount = YES;
            NSDictionary *result = [serializer serializeWithQuery:query];
            expect(result).to.equal(@{
                @"record_type" : @"recordType",
                @"limit" : @30,
                @"offset" : @5,
                @"count" : @YES,
            });
        });
    });

describe(@"serialize predicate", ^{
    __block SKYQuerySerializer *serializer = nil;
    __block NSDateFormatter *dateFormatter = nil;

    beforeEach(^{
        serializer = [SKYQuerySerializer serializer];
        dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZZZZZ"];
    });

    it(@"lhs key path", ^{
        NSArray *result = [serializer
            serializeWithPredicate:[NSPredicate predicateWithFormat:@"name = %@", @"Peter"]];
        expect([result class]).to.beSubclassOf([NSArray class]);
        expect(result).to.haveCountOf(3);
        expect(result[0]).to.equal(@"eq");
        expect([result[1] class]).to.beSubclassOf([NSDictionary class]);
        expect(result[1][@"$type"]).to.equal(@"keypath");
        expect(result[1][@"$val"]).to.equal(@"name");
        expect(result[2]).to.equal(@"Peter");
    });

    it(@"equal string", ^{
        NSArray *result = [serializer
            serializeWithPredicate:[NSPredicate predicateWithFormat:@"name = %@", @"Peter"]];
        expect([result class]).to.beSubclassOf([NSArray class]);
        expect(result[0]).to.equal(@"eq");
        expect(result[2]).to.equal(@"Peter");
    });

    it(@"equal integer", ^{
        NSArray *result =
            [serializer serializeWithPredicate:[NSPredicate predicateWithFormat:@"name = %d", 12]];
        expect([result class]).to.beSubclassOf([NSArray class]);
        expect(result[0]).to.equal(@"eq");
        expect(result[2]).to.equal(12);
    });

    it(@"equal number", ^{
        NSArray *result =
            [serializer serializeWithPredicate:[NSPredicate predicateWithFormat:@"name = %@", @12]];
        expect([result class]).to.beSubclassOf([NSArray class]);
        expect(result[0]).to.equal(@"eq");
        expect(result[2]).to.equal(12);
    });

    it(@"equal date", ^{
        NSDate *dob = [NSDate dateWithTimeIntervalSinceReferenceDate:0];
        NSArray *result =
            [serializer serializeWithPredicate:[NSPredicate predicateWithFormat:@"dob = %@", dob]];
        expect([result class]).to.beSubclassOf([NSArray class]);
        expect(result[0]).to.equal(@"eq");
        expect(result[2][@"$type"]).to.equal(@"date");
        expect([dateFormatter dateFromString:result[2][@"$date"]]).to.equal(dob);
    });

    it(@"equal ref", ^{
        SKYReference *ref = [[SKYReference alloc]
            initWithRecordID:[[SKYRecordID alloc] initWithRecordType:@"city" name:@"hongkong"]];
        NSArray *result =
            [serializer serializeWithPredicate:[NSPredicate predicateWithFormat:@"city = %@", ref]];
        expect([result class]).to.beSubclassOf([NSArray class]);
        expect(result[0]).to.equal(@"eq");
        expect(result[2]).to.equal(@{ @"$type" : @"ref", @"$id" : @"city/hongkong" });
    });

    it(@"equal ref to user record id", ^{
        SKYReference *ref = [[SKYReference alloc]
            initWithRecordID:[[SKYUserRecordID alloc] initWithUsername:@"john.doe@example.com"]];
        NSArray *result = [serializer
            serializeWithPredicate:[NSPredicate predicateWithFormat:@"_created_by = %@", ref]];
        expect([result class]).to.beSubclassOf([NSArray class]);
        expect(result[0]).to.equal(@"eq");
        expect(result[2]).to.equal(@{ @"$type" : @"ref", @"$id" : @"_user/john.doe@example.com" });
    });

    it(@"greater than integer", ^{
        NSArray *result =
            [serializer serializeWithPredicate:[NSPredicate predicateWithFormat:@"name > %d", 12]];
        expect([result class]).to.beSubclassOf([NSArray class]);
        expect(result[0]).to.equal(@"gt");
        expect(result[2]).to.equal(12);
    });

    it(@"greater than or equal integer", ^{
        NSArray *result =
            [serializer serializeWithPredicate:[NSPredicate predicateWithFormat:@"name >= %d", 12]];
        expect([result class]).to.beSubclassOf([NSArray class]);
        expect(result[0]).to.equal(@"gte");
        expect(result[2]).to.equal(12);
    });

    it(@"less than integer", ^{
        NSArray *result =
            [serializer serializeWithPredicate:[NSPredicate predicateWithFormat:@"name < %d", 12]];
        expect([result class]).to.beSubclassOf([NSArray class]);
        expect(result[0]).to.equal(@"lt");
        expect(result[2]).to.equal(12);
    });

    it(@"less than or equal integer", ^{
        NSArray *result =
            [serializer serializeWithPredicate:[NSPredicate predicateWithFormat:@"name <= %d", 12]];
        expect([result class]).to.beSubclassOf([NSArray class]);
        expect(result[0]).to.equal(@"lte");
        expect(result[2]).to.equal(12);
    });

    it(@"not equal integer", ^{
        NSArray *result =
            [serializer serializeWithPredicate:[NSPredicate predicateWithFormat:@"name <> %d", 12]];
        expect([result class]).to.beSubclassOf([NSArray class]);
        expect(result[0]).to.equal(@"neq");
        expect(result[2]).to.equal(12);
    });

    it(@"and", ^{
        NSArray *result = [serializer
            serializeWithPredicate:[NSPredicate predicateWithFormat:@"name = %@ && age >= %d",
                                                                    @"Peter", 12]];
        expect([result class]).to.beSubclassOf([NSArray class]);
        expect(result).to.haveCountOf(3);
        expect(result[0]).to.equal(@"and");
        expect([result[1] class]).to.beSubclassOf([NSArray class]);
        expect(result[1][0]).to.equal(@"eq");
        expect([result[2] class]).to.beSubclassOf([NSArray class]);
        expect(result[2][0]).to.equal(@"gte");
    });

    it(@"double and", ^{
        NSArray *result = [serializer
            serializeWithPredicate:
                [NSPredicate predicateWithFormat:@"name = %@ && age >= %d && interest <> %@",
                                                 @"Peter", 12, @"reading"]];
        expect([result class]).to.beSubclassOf([NSArray class]);
        expect(result).to.haveCountOf(4);
        expect(result[0]).to.equal(@"and");
        expect([result[1] class]).to.beSubclassOf([NSArray class]);
        expect(result[3][0]).to.equal(@"neq");
    });

    it(@"or", ^{
        NSArray *result = [serializer
            serializeWithPredicate:[NSPredicate predicateWithFormat:@"name = %@ || age >= %d",
                                                                    @"Peter", 12]];
        expect([result class]).to.beSubclassOf([NSArray class]);
        expect(result).to.haveCountOf(3);
        expect(result[0]).to.equal(@"or");
        expect([result[1] class]).to.beSubclassOf([NSArray class]);
        expect(result[1][0]).to.equal(@"eq");
        expect([result[2] class]).to.beSubclassOf([NSArray class]);
        expect(result[2][0]).to.equal(@"gte");
    });

    it(@"not", ^{
        NSArray *result = [serializer
            serializeWithPredicate:[NSPredicate predicateWithFormat:@"not (name = %@)", @"Peter"]];
        expect([result class]).to.beSubclassOf([NSArray class]);
        expect(result).to.haveCountOf(2);
        expect(result[0]).to.equal(@"not");
        expect([result[1] class]).to.beSubclassOf([NSArray class]);
        expect(result[1][0]).to.equal(@"eq");
    });

    it(@"distanceToLocation:fromLocation:", ^{
        CLLocation *loc = [[CLLocation alloc] initWithLatitude:1 longitude:2];
        NSArray *result = [serializer
            serializeWithPredicate:
                [NSPredicate
                    predicateWithFormat:@"distanceToLocation:fromLocation:(location, %@) < %f", loc,
                                        3.f]];

        expect(result).to.equal(@[
            @"lt",
            @[
               @"func",
               @"distance",
               @{ @"$type" : @"keypath",
                  @"$val" : @"location" },
               @{ @"$type" : @"geo",
                  @"$lng" : @2,
                  @"$lat" : @1 }
            ],
            @3,
        ]);
    });

    it(@"serialize beginswith", ^{
        NSArray *result = [serializer
            serializeWithPredicate:[NSPredicate
                                       predicateWithFormat:@"content BEGINSWITH %@", @"hello"]];

        expect(result)
            .to.equal(@[ @"like",
                         @{ @"$type" : @"keypath",
                            @"$val" : @"content" },
                         @"hello%" ]);
    });

    it(@"serialize endswith", ^{
        NSArray *result = [serializer
            serializeWithPredicate:[NSPredicate
                                       predicateWithFormat:@"content ENDSWITH %@", @"hello"]];

        expect(result)
            .to.equal(@[ @"like",
                         @{ @"$type" : @"keypath",
                            @"$val" : @"content" },
                         @"%hello" ]);
    });

    it(@"serialize contains", ^{
        NSArray *result = [serializer
            serializeWithPredicate:[NSPredicate
                                       predicateWithFormat:@"content CONTAINS %@", @"hello"]];

        expect(result)
            .to.equal(@[ @"like",
                         @{ @"$type" : @"keypath",
                            @"$val" : @"content" },
                         @"%hello%" ]);
    });

    it(@"serialize like", ^{
        NSArray *result =
            [serializer serializeWithPredicate:[NSPredicate predicateWithFormat:@"content LIKE %@",
                                                                                @"*hello?"]];

        expect(result)
            .to.equal(@[ @"like",
                         @{ @"$type" : @"keypath",
                            @"$val" : @"content" },
                         @"%hello_" ]);
    });

    it(@"serialize like[c]", ^{
        NSArray *result = [serializer
            serializeWithPredicate:[NSPredicate
                                       predicateWithFormat:@"content LIKE[c] %@", @"*hello?"]];

        expect(result)
            .to.equal(@[ @"ilike",
                         @{ @"$type" : @"keypath",
                            @"$val" : @"content" },
                         @"%hello_" ]);
    });

    it(@"serialize in", ^{
        NSArray *result = [serializer
            serializeWithPredicate:[NSPredicate predicateWithFormat:@"category IN %@",
                                                                    @[ @"recipe", @"fiction" ]]];

        expect(result).to.equal(@[
            @"in",
            @{ @"$type" : @"keypath",
               @"$val" : @"category" },
            @[ @"recipe", @"fiction" ]
        ]);
    });

    it(@"serialize in with string on left hand side", ^{
        NSArray *result =
            [serializer serializeWithPredicate:[NSPredicate predicateWithFormat:@"%@ IN categories",
                                                                                @"fiction"]];

        expect(result).to.equal(@[
            @"in",
            @"fiction",
            @{ @"$type" : @"keypath",
               @"$val" : @"categories" },
        ]);
    });

});

describe(@"serialize sort descriptors", ^{
    __block SKYQuerySerializer *serializer = nil;

    beforeEach(^{
        serializer = [SKYQuerySerializer serializer];
    });

    it(@"empty", ^{
        NSArray *result = [serializer serializeWithSortDescriptors:@[]];
        expect([result class]).to.beSubclassOf([NSArray class]);
        expect(result).to.haveCountOf(0);
    });

    it(@"sort asc", ^{
        NSArray *sd = @[ [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES] ];
        NSArray *result = [serializer serializeWithSortDescriptors:sd];
        expect([result class]).to.beSubclassOf([NSArray class]);
        expect(result).to.haveCountOf(1);
        expect(result[0][0]).to.equal(@{ @"$type" : @"keypath", @"$val" : @"name" });
        expect(result[0][1]).to.equal(@"asc");
    });

    it(@"sort desc", ^{
        NSArray *sd = @[ [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:NO] ];
        NSArray *result = [serializer serializeWithSortDescriptors:sd];
        expect([result class]).to.beSubclassOf([NSArray class]);
        expect(result).to.haveCountOf(1);
        expect(result[0][0]).to.equal(@{ @"$type" : @"keypath", @"$val" : @"name" });
        expect(result[0][1]).to.equal(@"desc");
    });

    it(@"sort multiple", ^{
        NSArray *sd = @[
            [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:NO],
            [NSSortDescriptor sortDescriptorWithKey:@"age" ascending:YES],
        ];
        NSArray *result = [serializer serializeWithSortDescriptors:sd];
        expect([result class]).to.beSubclassOf([NSArray class]);
        expect(result).to.haveCountOf(2);
        expect(result[0][0]).to.equal(@{ @"$type" : @"keypath", @"$val" : @"name" });
        expect(result[0][1]).to.equal(@"desc");
        expect(result[1][0]).to.equal(@{ @"$type" : @"keypath", @"$val" : @"age" });
        expect(result[1][1]).to.equal(@"asc");
    });

    it(@"sort by distance", ^{
        CLLocation *location = [[CLLocation alloc] initWithLatitude:42 longitude:24];
        NSArray *sd = @[
            [SKYLocationSortDescriptor locationSortDescriptorWithKey:@"latlng"
                                                    relativeLocation:location
                                                           ascending:YES]
        ];
        NSArray *result = [serializer serializeWithSortDescriptors:sd];
        NSArray *expected = @[
            @[
               @[
                  @"func",
                  @"distance",
                  @{ @"$type" : @"keypath",
                     @"$val" : @"latlng" },
                  @{ @"$type" : @"geo",
                     @"$lng" : @24,
                     @"$lat" : @42 },
               ],
               @"asc"
            ]
        ];

        expect(result).to.equal(expected);
    });

});

SpecEnd
