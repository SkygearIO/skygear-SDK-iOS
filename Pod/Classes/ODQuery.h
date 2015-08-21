//
//  ODQuery.h
//  askq
//
//  Created by Kenji Pa on 21/1/15.
//  Copyright (c) 2015 Rocky Chan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ODQuery : NSObject <NSSecureCoding>

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithRecordType:(NSString *)recordType
                         predicate:(NSPredicate *)predicate NS_DESIGNATED_INITIALIZER;

+ (instancetype)queryWithRecordType:(NSString *)recordType
                          predicate:(NSPredicate *)predicate;

@property (nonatomic, readonly, copy) NSString *recordType;
@property (nonatomic, readonly, copy) NSPredicate *predicate;
@property (nonatomic, copy) NSArray *sortDescriptors;

/**
 An NSDictionary of expression to be evaluated on the server side and returned as transient
 dictionary in ODRecord.
 */
@property (strong, nonatomic) NSDictionary *transientIncludes;

@end
