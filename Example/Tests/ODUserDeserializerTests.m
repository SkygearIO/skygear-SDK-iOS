//
//  ODUserDeserializerTests.m
//  ODKit
//
//  Created by Kenji Pa on 1/6/15.
//  Copyright (c) 2015 Kwok-kuen Cheung. All rights reserved.
//

#import <ODKit/ODKit.h>

SpecBegin(ODUserDeserializerTests)

describe(@"deserialize", ^{
    __block ODUserDeserializer *deserializer = nil;

    beforeEach(^{
        deserializer = [ODUserDeserializer deserializer];
    });

    it(@"init", ^{
        ODUserDeserializer *deserializer = [ODUserDeserializer deserializer];
        expect([deserializer class]).to.beSubclassOf([ODUserDeserializer class]);
    });

    it(@"return nil on nil", ^{
        ODUser *user = [deserializer userWithDictionary:nil];
        expect(user).to.beNil();
    });

    it(@"return nil on empty dict", ^{
        ODUser *user = [deserializer userWithDictionary:@{}];
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

        ODUser *user = [deserializer userWithDictionary:data];
        expect(user.username).to.equal(@"userid");
        expect(user.email).to.equal(@"john.doe@gmail.com");
        expect(user.authData).to.equal(@{@"authMethod": @{@"key": @"value"}});
    });

    it(@"deserialize user with id only", ^{
        NSDictionary *data = @{@"_id": @"userid"};
        ODUser *user = [deserializer userWithDictionary:data];
        expect(user.username).to.equal(@"userid");
    });

    it(@"return nil if id is missing", ^{
        NSDictionary *data = @{
                               @"email": @"john.doe@gmail.com",
                               @"authData": @{
                                       @"authMethod": @{@"key": @"value"},
                                       },
                               };
        ODUser *user = [deserializer userWithDictionary:data];
        expect(user).to.beNil();
    });
});

SpecEnd