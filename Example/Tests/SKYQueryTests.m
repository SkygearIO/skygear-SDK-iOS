//
//  SKYQueryTests.m
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

#import <Foundation/Foundation.h>
#import <OHHTTPStubs/OHHTTPStubs.h>
#import <SKYKit/SKYKit.h>
#import <SKYKit/SKYQuery+Caching.h>

SpecBegin(SKYQuery)

    describe(@"SKYQuery", ^{
        beforeAll(^{
            [NSKeyedUnarchiver setClass:[SKYQuery class] forClassName:NSStringFromClass([SKYQuery class])];
        });

        it(@"equals", ^{
            NSString *recordType = @"book";
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"title = %@", @"A tale of two cities"];
            SKYQuery *query1 = [SKYQuery queryWithRecordType:[recordType copy] predicate:[predicate copy]];
            query1.sortDescriptors = @[ [NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES] ];
            query1.transientIncludes = @{@"city" : [NSExpression expressionForKeyPath:@"city"]};
            SKYQuery *query2 = [[SKYQuery alloc] initWithRecordType:[recordType copy] predicate:[predicate copy]];
            query2.sortDescriptors = [query1.sortDescriptors copy];
            query2.transientIncludes = [query1.transientIncludes copy];
            query1.limit = query2.limit;
            query1.offset = query2.offset;
            expect(query1).to.equal(query2);
        });

        it(@"not equals", ^{
            SKYQuery *query1 =
                [SKYQuery queryWithRecordType:@"book"
                                    predicate:[NSPredicate predicateWithFormat:@"title = %@", @"A tale of one city"]];
            SKYQuery *query2 = [[SKYQuery alloc]
                initWithRecordType:@"book"
                         predicate:[NSPredicate predicateWithFormat:@"title = %@", @"A tale of two cities"]];
            expect(query1).toNot.equal(query2);
        });

        it(@"coding", ^{
            SKYQuery *query =
                [SKYQuery queryWithRecordType:@"book"
                                    predicate:[NSPredicate predicateWithFormat:@"title = %@", @"A tale of two cities"]];
            NSData *data = [NSKeyedArchiver archivedDataWithRootObject:query];
            SKYQuery *decodedQuery = [NSKeyedUnarchiver unarchiveObjectWithData:data];
            expect(decodedQuery).to.equal(query);
        });
    });

describe(@"SKYQueryCaching", ^{
    it(@"cache key", ^{
        SKYQuery *query =
            [SKYQuery queryWithRecordType:@"book"
                                predicate:[NSPredicate predicateWithFormat:@"title = %@", @"A tale of two cities"]];
        expect([[query cacheKey] class]).to.beSubclassOf([NSString class]);
    });
});

SpecEnd
