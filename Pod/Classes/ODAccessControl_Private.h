//
//  ODAccessControl_Private.h
//  Pods
//
//  Created by Kenji Pa on 11/6/15.
//
//

#import "ODAccessControl.h"

@interface ODAccessControl()

+ (instancetype)publicReadWriteAccessControl;
+ (instancetype)accessControlWithEntries:(NSArray /* ODAccessControlEntry */ *)entries;

- (instancetype)initForPublicReadWrite NS_DESIGNATED_INITIALIZER;
- (instancetype)initWithEntries:(NSArray /* ODAccessControlEntry */ *)entries NS_DESIGNATED_INITIALIZER;

@property (strong, nonatomic) NSMutableOrderedSet *entries;
@property (nonatomic, readwrite) BOOL public;

@end
