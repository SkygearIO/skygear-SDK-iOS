//
//  ODLocationSortDescriptorTests.m
//  ODKit
//
//  Created by atwork on 19/8/15.
//  Copyright (c) 2015 Kwok-kuen Cheung. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <OHHTTPStubs/OHHTTPStubs.h>
#import "ODLocationSortDescriptor.h"
#import <CoreLocation/CoreLocation.h>
#import "ODRecord.h"

SpecBegin(ODLocationSortDescriptor)

describe(@"location", ^{
    ODRecord *city1 = [ODRecord recordWithRecordType:@"city"
                                                name:@"hongkong"
                                                data:@{@"latlng": [[CLLocation alloc] initWithLatitude:22.3 longitude:114.2]}];
    ODRecord *city2 = [ODRecord recordWithRecordType:@"city"
                                                name:@"newyork"
                                                data:@{@"latlng": [[CLLocation alloc] initWithLatitude:40.7127 longitude:-74.0059]}];
    ODRecord *city3 = [ODRecord recordWithRecordType:@"city"
                                                name:@"london"
                                                data:@{@"latlng": [[CLLocation alloc] initWithLatitude:51.507222 longitude:-0.1275]}];
    ODRecord *city4 = [ODRecord recordWithRecordType:@"city"
                                                name:@"paris"
                                                data:@{@"latlng": [[CLLocation alloc] initWithLatitude:48.8567 longitude:2.3508]}];
    CLLocation *relativeLocation = [[CLLocation alloc] initWithLatitude:48.8567 longitude:2.3508];
    
    it(@"init", ^{
        ODLocationSortDescriptor *sd = [ODLocationSortDescriptor locationSortDescriptorWithKey:@"latlng"
                                                                              relativeLocation:relativeLocation
                                                                                     ascending:YES];
        expect(sd.key).to.equal(@"latlng");
        expect([sd.relativeLocation distanceFromLocation:relativeLocation]).to.beLessThan(0.00001);
        expect(sd.relativeLocation).toNot.beIdenticalTo(relativeLocation);
        expect(sd.ascending).to.beTruthy();
    });
    
    it(@"class method init", ^{
        ODLocationSortDescriptor *sd = [ODLocationSortDescriptor locationSortDescriptorWithKey:@"latlng"
                                                                              relativeLocation:relativeLocation
                                                                                     ascending:YES];
        expect(sd.key).to.equal(@"latlng");
        expect([sd.relativeLocation distanceFromLocation:relativeLocation]).to.beLessThan(0.00001);
        expect(sd.relativeLocation).toNot.beIdenticalTo(relativeLocation);
        expect(sd.ascending).to.beTruthy();
    });
    
    it(@"compare", ^{
        ODLocationSortDescriptor *sd = [ODLocationSortDescriptor locationSortDescriptorWithKey:@"latlng"
                                                                              relativeLocation:relativeLocation
                                                                                     ascending:YES];
        expect([sd compareObject:city3 toObject:city1]).to.equal(NSOrderedAscending);
        expect([sd compareObject:city2 toObject:city3]).to.equal(NSOrderedDescending);
        expect([sd compareObject:city2 toObject:city2]).to.equal(NSOrderedSame);
        expect(sd.ascending).to.beTruthy();
    });
    
    it(@"sort", ^{
        ODLocationSortDescriptor *sd = [ODLocationSortDescriptor locationSortDescriptorWithKey:@"latlng"
                                                                              relativeLocation:relativeLocation
                                                                                     ascending:YES];
        NSArray *cities = @[city1, city3, city2, city4];
        NSArray *sortedCities = [cities sortedArrayUsingDescriptors:@[sd]];
        expect(sortedCities).to.equal(@[city4, city3, city2, city1]);
        expect(sd.ascending).to.beTruthy();
    });
    
    it(@"coding", ^{
        ODLocationSortDescriptor *sd = [ODLocationSortDescriptor locationSortDescriptorWithKey:@"latlng"
                                                                              relativeLocation:relativeLocation
                                                                                     ascending:YES];
        
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:sd];
        ODLocationSortDescriptor *sd2 = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        expect(sd2.key).to.equal(@"latlng");
        expect([sd2.relativeLocation distanceFromLocation:relativeLocation]).to.beLessThan(0.00001);
        expect(sd2.ascending).to.beTruthy();
    });
    
    it(@"reverse", ^{
        ODLocationSortDescriptor *sd = [ODLocationSortDescriptor locationSortDescriptorWithKey:@"latlng"
                                                                              relativeLocation:relativeLocation
                                                                                     ascending:YES];
        ODLocationSortDescriptor *reversed = [sd reversedSortDescriptor];
        
        expect(reversed.key).to.equal(@"latlng");
        expect([reversed.relativeLocation distanceFromLocation:relativeLocation]).to.beLessThan(0.00001);
        expect(reversed.ascending).to.beFalsy();
    });

});

SpecEnd
        
