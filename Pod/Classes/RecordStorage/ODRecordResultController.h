//
//  ODRecordResultController.h
//  Pods
//
//  Created by atwork on 4/5/15.
//
//

#import <Foundation/Foundation.h>

@class ODRecord;

/**
 An <ODRecordResultController> is used for efficient access of <ODRecord>s
 that are the result of a query operation.
 */
@interface ODRecordResultController : NSObject

/**
 The number of records contained in the result.
 */
@property (nonatomic, readonly) NSUInteger numberOfRecords;

/**
 Returns a record at the specified index path.
 */
- (ODRecord *)recordAtIndexPath:(NSIndexPath *)indexPath;

@end
