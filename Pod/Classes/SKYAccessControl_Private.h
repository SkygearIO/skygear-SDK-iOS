//
//  SKYAccessControl_Private.h
//  Pods
//
//  Created by Kenji Pa on 11/6/15.
//
//

#import "SKYAccessControl.h"

@interface SKYAccessControl ()

+ (instancetype)publicReadWriteAccessControl;
+ (instancetype)accessControlWithEntries:(NSArray /* SKYAccessControlEntry */ *)entries;

- (instancetype)initForPublicReadWrite NS_DESIGNATED_INITIALIZER;
- (instancetype)initWithEntries:(NSArray /* SKYAccessControlEntry */ *)entries
    NS_DESIGNATED_INITIALIZER;

@property (strong, nonatomic) NSMutableOrderedSet *entries;
@property (nonatomic, readwrite) BOOL public;

@end
