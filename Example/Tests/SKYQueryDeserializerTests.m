//
//  SKYQueryDeserializerTests.m
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
#import <SKYKit/SKYKit.h>
#import <UIKit/UIKit.h>

SpecBegin(SKYQueryDeserializer)

    describe(@"deserialize query", ^{
        __block SKYQueryDeserializer *deserializer = nil;
        __block SKYQuery *query = nil;

        beforeEach(^{
            deserializer = [SKYQueryDeserializer deserializer];
            query = [[SKYQuery alloc] initWithRecordType:@"recordType" predicate:nil];
        });

        it(@"init", ^{
            SKYQueryDeserializer *deserializer = [SKYQueryDeserializer deserializer];
            expect([deserializer class]).to.beSubclassOf([SKYQueryDeserializer class]);
        });

        it(@"deserialize transient includes", ^{
            NSDictionary *queryDict = @{
                @"record_type" : @"recordType",
                @"include" : @{
                    @"city" : @{@"$type" : @"keypath", @"$val" : @"city"},
                }
            };

            SKYQuery *query = [deserializer queryWithDictionary:queryDict];
            expect(query.recordType).to.equal(@"recordType");
            NSExpression *cityKeyPath = query.transientIncludes[@"city"];
            expect([cityKeyPath class]).to.beSubclassOf([NSExpression class]);
            expect(cityKeyPath.expressionType).to.equal(NSKeyPathExpressionType);
            expect(cityKeyPath.keyPath).to.equal(@"city");
            expect(query.predicate).to.equal(nil);
        });

        it(@"deserialize predicate", ^{
            NSDictionary *queryDict = @{
                @"record_type" : @"recordType",
                @"predicate" : @[ @"eq", @{@"$type" : @"keypath", @"$val" : @"name"}, @"John" ],
            };

            SKYQuery *query = [deserializer queryWithDictionary:queryDict];
            expect(query.recordType).to.equal(@"recordType");
            expect(query.predicate)
                .to.equal([NSPredicate predicateWithFormat:@"name = %@", @"John"]);
        });

        it(@"deserialize sort", ^{
            NSDictionary *queryDict = @{
                @"record_type" : @"recordType",
                @"sort" : @[ @[ @{@"$type" : @"keypath", @"$val" : @"name"}, @"asc" ] ],
            };

            SKYQuery *query = [deserializer queryWithDictionary:queryDict];
            expect(query.recordType).to.equal(@"recordType");
            expect(query.sortDescriptors).to.equal(@[
                [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES],
            ]);
        });

        it(@"deserialize limit, offset and overallCount", ^{
            NSDictionary *queryDict = @{
                @"record_type" : @"recordType",
                @"limit" : @30,
                @"offset" : @5,
                @"count" : @YES,
            };

            SKYQuery *query = [deserializer queryWithDictionary:queryDict];
            expect(query.recordType).to.equal(@"recordType");
            expect(query.limit).to.equal(30);
            expect(query.offset).to.equal(5);
            expect(query.overallCount).to.equal(YES);
        });
    });

describe(@"deserialize predicate", ^{
    __block SKYQueryDeserializer *deserializer = nil;

    beforeEach(^{
        deserializer = [SKYQueryDeserializer deserializer];
    });

    it(@"equal string", ^{
        NSArray *predicateArray = @[ @"eq", @{@"$type" : @"keypath", @"$val" : @"name"}, @"Peter" ];

        NSPredicate *predicate = [deserializer predicateWithArray:predicateArray];
        expect(predicate).to.equal([NSPredicate predicateWithFormat:@"name = %@", @"Peter"]);
    });

    it(@"equal integer", ^{
        NSArray *predicateArray = @[ @"eq", @{@"$type" : @"keypath", @"$val" : @"name"}, @12 ];

        NSPredicate *predicate = [deserializer predicateWithArray:predicateArray];
        expect(predicate).to.equal([NSPredicate predicateWithFormat:@"name = %@", @12]);
    });

    it(@"equal float", ^{
        NSArray *predicateArray = @[ @"eq", @{@"$type" : @"keypath", @"$val" : @"name"}, @12.1 ];

        NSPredicate *predicate = [deserializer predicateWithArray:predicateArray];
        expect(predicate).to.equal([NSPredicate predicateWithFormat:@"name = %@", @12.1]);
    });

    it(@"equal date", ^{
        NSArray *predicateArray = @[
            @"eq", @{@"$type" : @"keypath", @"$val" : @"dob"},
            @{@"$type" : @"date", @"$date" : @"2015-02-02T01:43:19.000Z"}
        ];

        NSPredicate *predicate = [deserializer predicateWithArray:predicateArray];
        expect(predicate).to.equal([NSPredicate
            predicateWithFormat:@"dob = %@", [NSDate dateWithTimeIntervalSince1970:1422841399]]);
    });

    it(@"equal reference", ^{
        NSArray *predicateArray = @[
            @"eq", @{@"$type" : @"keypath", @"$val" : @"city"},
            @{@"$type" : @"ref", @"$id" : @"city/hongkong"}
        ];

        NSPredicate *predicate = [deserializer predicateWithArray:predicateArray];
        SKYReference *reference = [[SKYReference alloc]
            initWithRecordID:[[SKYRecordID alloc] initWithRecordType:@"city" name:@"hongkong"]];
        expect(predicate).to.equal([NSPredicate predicateWithFormat:@"city = %@", reference]);
    });

    it(@"greater than integer", ^{
        NSArray *predicateArray = @[ @"gt", @{@"$type" : @"keypath", @"$val" : @"name"}, @12 ];

        NSPredicate *predicate = [deserializer predicateWithArray:predicateArray];
        expect(predicate).to.equal([NSPredicate predicateWithFormat:@"name > %@", @12]);
    });

    it(@"greater than or equal to integer", ^{
        NSArray *predicateArray = @[ @"gte", @{@"$type" : @"keypath", @"$val" : @"name"}, @12 ];

        NSPredicate *predicate = [deserializer predicateWithArray:predicateArray];
        expect(predicate).to.equal([NSPredicate predicateWithFormat:@"name >= %@", @12]);
    });

    it(@"less than integer", ^{
        NSArray *predicateArray = @[ @"lt", @{@"$type" : @"keypath", @"$val" : @"name"}, @12 ];

        NSPredicate *predicate = [deserializer predicateWithArray:predicateArray];
        expect(predicate).to.equal([NSPredicate predicateWithFormat:@"name < %@", @12]);
    });

    it(@"less than or equal to integer", ^{
        NSArray *predicateArray = @[ @"lte", @{@"$type" : @"keypath", @"$val" : @"name"}, @12 ];

        NSPredicate *predicate = [deserializer predicateWithArray:predicateArray];
        expect(predicate).to.equal([NSPredicate predicateWithFormat:@"name <= %@", @12]);
    });

    it(@"not equal integer", ^{
        NSArray *predicateArray = @[ @"neq", @{@"$type" : @"keypath", @"$val" : @"name"}, @12 ];

        NSPredicate *predicate = [deserializer predicateWithArray:predicateArray];
        expect(predicate).to.equal([NSPredicate predicateWithFormat:@"name <> %@", @12]);
    });

    it(@"func distance", ^{
        NSArray *predicateArray = @[
            @"lt",
            @[
                @"func", @"distance", @{@"$type" : @"keypath", @"$val" : @"location"},
                @{ @"$type" : @"geo",
                   @"$lng" : @2,
                   @"$lat" : @1 }
            ],
            @3,
        ];

        // CLLocation doesn't implement isEqualTo, checking it manually here

        id predicate = [deserializer predicateWithArray:predicateArray];
        expect(predicate).to.beInstanceOf([NSComparisonPredicate class]);

        NSExpression *leftExpression = [predicate leftExpression];
        expect(leftExpression.function).to.equal(@"distanceToLocation:fromLocation:");

        expect(leftExpression.arguments.count).to.equal(2);
        expect(leftExpression.arguments[0])
            .to.equal([NSExpression expressionForKeyPath:@"location"]);
        CLLocation *loc = [leftExpression.arguments[1] constantValue];
        expect(loc.coordinate).to.equal(CLLocationCoordinate2DMake(1, 2));

        expect([predicate rightExpression]).to.equal([NSExpression expressionForConstantValue:@3]);
    });

    it(@"like", ^{
        NSArray *predicateArray =
            @[ @"like", @{@"$type" : @"keypath", @"$val" : @"content"}, @"%hello_" ];

        NSPredicate *predicate = [deserializer predicateWithArray:predicateArray];
        expect(predicate).to.equal(
            [NSPredicate predicateWithFormat:@"content LIKE %@", @"*hello?"]);
    });

    it(@"ilike", ^{
        NSArray *predicateArray =
            @[ @"ilike", @{@"$type" : @"keypath", @"$val" : @"content"}, @"%hello_" ];

        NSPredicate *predicate = [deserializer predicateWithArray:predicateArray];
        expect(predicate).to.equal(
            [NSPredicate predicateWithFormat:@"content LIKE[c] %@", @"*hello?"]);
    });

    it(@"in", ^{
        NSArray *predicateArray =
            @[ @"in", @{@"$type" : @"keypath", @"$val" : @"category"}, @[ @"recipe", @"fiction" ] ];

        NSPredicate *predicate = [deserializer predicateWithArray:predicateArray];
        expect(predicate).to.equal(
            [NSPredicate predicateWithFormat:@"category IN %@", @[ @"recipe", @"fiction" ]]);
    });

    it(@"and", ^{
        NSArray *predicateArray = @[
            @"and", @[ @"eq", @{@"$type" : @"keypath", @"$val" : @"name"}, @"Peter" ],
            @[ @"gte", @{@"$type" : @"keypath", @"$val" : @"age"}, @12 ]
        ];

        NSPredicate *predicate = [deserializer predicateWithArray:predicateArray];
        expect(predicate).to.equal(
            [NSPredicate predicateWithFormat:@"name = %@ && age >= %d", @"Peter", 12]);
    });

    it(@"double and", ^{
        NSArray *predicateArray = @[
            @"and", @[ @"eq", @{@"$type" : @"keypath", @"$val" : @"name"}, @"Peter" ],
            @[ @"gte", @{@"$type" : @"keypath", @"$val" : @"age"}, @12 ],
            @[ @"neq", @{@"$type" : @"keypath", @"$val" : @"interest"}, @"reading" ]
        ];

        NSPredicate *predicate = [deserializer predicateWithArray:predicateArray];
        expect(predicate).to.equal(
            [NSPredicate predicateWithFormat:@"name = %@ && age >= %d && interest <> %@", @"Peter",
                                             12, @"reading"]);
    });

    it(@"or", ^{
        NSArray *predicateArray = @[
            @"or", @[ @"eq", @{@"$type" : @"keypath", @"$val" : @"name"}, @"Peter" ],
            @[ @"gte", @{@"$type" : @"keypath", @"$val" : @"age"}, @12 ]
        ];

        NSPredicate *predicate = [deserializer predicateWithArray:predicateArray];
        expect(predicate).to.equal(
            [NSPredicate predicateWithFormat:@"name = %@ || age >= %d", @"Peter", 12]);
    });

    it(@"not", ^{
        NSArray *predicateArray =
            @[ @"not", @[ @"eq", @{@"$type" : @"keypath", @"$val" : @"name"}, @"Peter" ] ];

        NSPredicate *predicate = [deserializer predicateWithArray:predicateArray];
        expect(predicate).to.equal([NSPredicate predicateWithFormat:@"not (name = %@)", @"Peter"]);
    });

    it(@"user relation", ^{
        NSArray *predicateArray = @[
            @"func", @"userRelation", @{@"$type" : @"keypath", @"$val" : @"_owner"},
            @{@"$type" : @"relation", @"$name" : @"_follow", @"$direction" : @"outward"}
        ];

        SKYRelationPredicate *predicate =
            (SKYRelationPredicate *)[deserializer predicateWithArray:predicateArray];
        expect([predicate class]).to.beSubclassOf([SKYRelationPredicate class]);
        expect(predicate.relation.name).to.equal(@"follow");
        expect(predicate.relation.direction).to.equal(SKYRelationDirectionOutward);
        expect(predicate.keyPath).to.equal(@"_owner");
    });
});

describe(@"deserialize sort descriptors", ^{
    __block SKYQueryDeserializer *deserializer = nil;

    beforeEach(^{
        deserializer = [SKYQueryDeserializer deserializer];
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
        NSArray *sdArray = @[ @[ @{@"$type" : @"keypath", @"$val" : @"name"}, @"asc" ] ];

        NSArray *sortDescriptors = [deserializer sortDescriptorsWithArray:sdArray];
        expect(sortDescriptors).to.equal(@[ [NSSortDescriptor sortDescriptorWithKey:@"name"
                                                                          ascending:YES] ]);
    });

    it(@"sort desc", ^{
        NSArray *sdArray = @[ @[ @{@"$type" : @"keypath", @"$val" : @"name"}, @"desc" ] ];

        NSArray *sortDescriptors = [deserializer sortDescriptorsWithArray:sdArray];
        expect(sortDescriptors).to.equal(@[ [NSSortDescriptor sortDescriptorWithKey:@"name"
                                                                          ascending:NO] ]);
    });

    it(@"sort multiple", ^{
        NSArray *sdArray = @[
            @[ @{@"$type" : @"keypath", @"$val" : @"name"}, @"desc" ],
            @[ @{@"$type" : @"keypath", @"$val" : @"age"}, @"asc" ],
        ];

        NSArray *sortDescriptors = [deserializer sortDescriptorsWithArray:sdArray];
        expect(sortDescriptors).to.equal(@[
            [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:NO],
            [NSSortDescriptor sortDescriptorWithKey:@"age" ascending:YES],
        ]);
    });

    it(@"sort distance", ^{
        NSArray *sdArray = @[
            @[
                @[
                    @"func", @"distance", @{@"$type" : @"keypath", @"$val" : @"latlng"},
                    @{ @"$type" : @"geo",
                       @"$lng" : @2,
                       @"$lat" : @1 }
                ],
                @"asc"
            ],
        ];

        NSArray *sortDescriptors = [deserializer sortDescriptorsWithArray:sdArray];
        expect(sortDescriptors).to.haveCountOf(1);
        expect([sortDescriptors[0] class]).to.beSubclassOf([SKYLocationSortDescriptor class]);

        SKYLocationSortDescriptor *sd = sortDescriptors[0];
        CLLocation *expectedLocation = [[CLLocation alloc] initWithLatitude:1 longitude:2];
        expect(sd.key).to.equal(@"latlng");
        expect([sd.relativeLocation distanceFromLocation:expectedLocation]).to.beLessThan(0.00001);
        expect(sd.ascending).to.equal(YES);

    });
});

SpecEnd
