//
//  SKYUserDeserializerTests.m
//  SkyKit
//
//  Created by Kenji Pa on 1/6/15.
//  Copyright (c) 2015 Kwok-kuen Cheung. All rights reserved.
//

#import <SkyKit/SkyKit.h>

SpecBegin(SKYUserDeserializerTests)

describe(@"deserialize", ^{
    __block SKYUserDeserializer *deserializer = nil;

    beforeEach(^{
        deserializer = [SKYUserDeserializer deserializer];
    });

    it(@"init", ^{
        SKYUserDeserializer *deserializer = [SKYUserDeserializer deserializer];
        expect([deserializer class]).to.beSubclassOf([SKYUserDeserializer class]);
    });

    it(@"return nil on nil", ^{
        SKYUser *user = [deserializer userWithDictionary:nil];
        expect(user).to.beNil();
    });

    it(@"return nil on empty dict", ^{
        SKYUser *user = [deserializer userWithDictionary:@{}];
        expect(user).to.beNil();
    });

    it(@"deserialize user", ^{
        NSDictionary *data = @{
                               @"_id": @"userid",
                               @"email": @"john.doe@gmail.com",
                               @"authData": @{
                                       @"authMethod": @{@"key": @"value"},
                                       },
                               };

        SKYUser *user = [deserializer userWithDictionary:data];
        expect(user.username).to.equal(@"userid");
        expect(user.email).to.equal(@"john.doe@gmail.com");
        expect(user.authData).to.equal(@{@"authMethod": @{@"key": @"value"}});
    });

    it(@"deserialize user with id only", ^{
        NSDictionary *data = @{@"_id": @"userid"};
        SKYUser *user = [deserializer userWithDictionary:data];
        expect(user.username).to.equal(@"userid");
    });

    it(@"return nil if id is missing", ^{
        NSDictionary *data = @{
                               @"email": @"john.doe@gmail.com",
                               @"authData": @{
                                       @"authMethod": @{@"key": @"value"},
                                       },
                               };
        SKYUser *user = [deserializer userWithDictionary:data];
        expect(user).to.beNil();
    });
});

SpecEnd
