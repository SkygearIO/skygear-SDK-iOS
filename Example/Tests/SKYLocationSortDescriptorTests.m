//
//  SKYLocationSortDescriptorTests.m
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

#import "SKYLocationSortDescriptor.h"
#import "SKYRecord.h"
#import <CoreLocation/CoreLocation.h>
#import <Foundation/Foundation.h>
#import <OHHTTPStubs/OHHTTPStubs.h>

SpecBegin(SKYLocationSortDescriptor)

    describe(@"location", ^{
        SKYRecord *city1 =
            [SKYRecord recordWithRecordType:@"city"
                                       name:@"hongkong"
                                       data:@{@"latlng" : [[CLLocation alloc] initWithLatitude:22.3 longitude:114.2]}];
        SKYRecord *city2 = [SKYRecord
            recordWithRecordType:@"city"
                            name:@"newyork"
                            data:@{@"latlng" : [[CLLocation alloc] initWithLatitude:40.7127 longitude:-74.0059]}];
        SKYRecord *city3 = [SKYRecord
            recordWithRecordType:@"city"
                            name:@"london"
                            data:@{@"latlng" : [[CLLocation alloc] initWithLatitude:51.507222 longitude:-0.1275]}];
        SKYRecord *city4 = [SKYRecord
            recordWithRecordType:@"city"
                            name:@"paris"
                            data:@{@"latlng" : [[CLLocation alloc] initWithLatitude:48.8567 longitude:2.3508]}];
        CLLocation *relativeLocation = [[CLLocation alloc] initWithLatitude:48.8567 longitude:2.3508];

        it(@"init", ^{
            SKYLocationSortDescriptor *sd = [SKYLocationSortDescriptor locationSortDescriptorWithKey:@"latlng"
                                                                                    relativeLocation:relativeLocation
                                                                                           ascending:YES];
            expect(sd.key).to.equal(@"latlng");
            expect([sd.relativeLocation distanceFromLocation:relativeLocation]).to.beLessThan(0.00001);
            expect(sd.relativeLocation).toNot.beIdenticalTo(relativeLocation);
            expect(sd.ascending).to.beTruthy();
        });

        it(@"class method init", ^{
            SKYLocationSortDescriptor *sd = [SKYLocationSortDescriptor locationSortDescriptorWithKey:@"latlng"
                                                                                    relativeLocation:relativeLocation
                                                                                           ascending:YES];
            expect(sd.key).to.equal(@"latlng");
            expect([sd.relativeLocation distanceFromLocation:relativeLocation]).to.beLessThan(0.00001);
            expect(sd.relativeLocation).toNot.beIdenticalTo(relativeLocation);
            expect(sd.ascending).to.beTruthy();
        });

        it(@"compare", ^{
            SKYLocationSortDescriptor *sd = [SKYLocationSortDescriptor locationSortDescriptorWithKey:@"latlng"
                                                                                    relativeLocation:relativeLocation
                                                                                           ascending:YES];
            expect([sd compareObject:city3 toObject:city1]).to.equal(NSOrderedAscending);
            expect([sd compareObject:city2 toObject:city3]).to.equal(NSOrderedDescending);
            expect([sd compareObject:city2 toObject:city2]).to.equal(NSOrderedSame);
            expect(sd.ascending).to.beTruthy();
        });

        it(@"sort", ^{
            SKYLocationSortDescriptor *sd = [SKYLocationSortDescriptor locationSortDescriptorWithKey:@"latlng"
                                                                                    relativeLocation:relativeLocation
                                                                                           ascending:YES];
            NSArray *cities = @[ city1, city3, city2, city4 ];
            NSArray *sortedCities = [cities sortedArrayUsingDescriptors:@[ sd ]];
            expect(sortedCities).to.equal(@[ city4, city3, city2, city1 ]);
            expect(sd.ascending).to.beTruthy();
        });

        it(@"coding", ^{
            SKYLocationSortDescriptor *sd = [SKYLocationSortDescriptor locationSortDescriptorWithKey:@"latlng"
                                                                                    relativeLocation:relativeLocation
                                                                                           ascending:YES];

            NSData *data = [NSKeyedArchiver archivedDataWithRootObject:sd];
            SKYLocationSortDescriptor *sd2 = [NSKeyedUnarchiver unarchiveObjectWithData:data];
            expect(sd2.key).to.equal(@"latlng");
            expect([sd2.relativeLocation distanceFromLocation:relativeLocation]).to.beLessThan(0.00001);
            expect(sd2.ascending).to.beTruthy();
        });

        it(@"reverse", ^{
            SKYLocationSortDescriptor *sd = [SKYLocationSortDescriptor locationSortDescriptorWithKey:@"latlng"
                                                                                    relativeLocation:relativeLocation
                                                                                           ascending:YES];
            SKYLocationSortDescriptor *reversed = [sd reversedSortDescriptor];

            expect(reversed.key).to.equal(@"latlng");
            expect([reversed.relativeLocation distanceFromLocation:relativeLocation]).to.beLessThan(0.00001);
            expect(reversed.ascending).to.beFalsy();
        });
    });

SpecEnd
