//
//  ODODQueryTests.m
//  ODKit
//
//  Created by atwork on 13/4/15.
//  Copyright (c) 2015 Kwok-kuen Cheung. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <OHHTTPStubs/OHHTTPStubs.h>
#import <ODKit/ODKit.h>
#import <ODKit/ODQuery+Caching.h>

SpecBegin(ODQuery)

describe(@"ODQuery", ^{
    
    beforeAll(^{
        [NSKeyedUnarchiver setClass:[ODQuery class]
                       forClassName:NSStringFromClass([ODQuery class])];
    });
    
    it(@"equals", ^{
        NSString *recordType = @"book";
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"title = %@", @"A tale of two cities"];
        ODQuery *query1 = [ODQuery queryWithRecordType:[recordType copy]
                                             predicate:[predicate copy]];
        query1.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES]];
        query1.eagerLoadKeyPath = @"title";
        ODQuery *query2 = [[ODQuery alloc] initWithRecordType:[recordType copy]
                                                    predicate:[predicate copy]];
        query2.sortDescriptors = [query1.sortDescriptors copy];
        query2.eagerLoadKeyPath = [query1.eagerLoadKeyPath copy];
        expect(query1).to.equal(query2);
    });
    
    it(@"not equals", ^{
        ODQuery *query1 = [ODQuery queryWithRecordType:@"book"
                                             predicate:[NSPredicate predicateWithFormat:@"title = %@", @"A tale of one city"]];
        ODQuery *query2 = [[ODQuery alloc] initWithRecordType:@"book"
                                                    predicate:[NSPredicate predicateWithFormat:@"title = %@", @"A tale of two cities"]];
        expect(query1).toNot.equal(query2);
    });
    
    it(@"coding", ^{
        ODQuery *query = [ODQuery queryWithRecordType:@"book"
                                            predicate:[NSPredicate predicateWithFormat:@"title = %@", @"A tale of two cities"]];
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:query];
        ODQuery *decodedQuery = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        expect(decodedQuery).to.equal(query);
    });
});

describe(@"ODQueryCaching", ^{
    it(@"cache key", ^{
        ODQuery *query = [ODQuery queryWithRecordType:@"book"
                                            predicate:[NSPredicate predicateWithFormat:@"title = %@", @"A tale of two cities"]];
        expect([[query cacheKey] class]).to.beSubclassOf([NSString class]);
    });
});

SpecEnd