//
//  ODOperation+OverrideLifeCycle.h
//  Pods
//
//  Created by Kenji Pa on 7/7/15.
//
//

#import "ODOperation.h"

@interface ODOperation (OverrideLifeCycle)

// expose underlying setExecuting: and setFinished: methods as we are handling operation
// life cycle ourselves
- (void)setExecuting:(BOOL)aBOOL;
- (BOOL)setFinished:(BOOL)aBOOL;

@end
