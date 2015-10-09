//
//  SKYRecordResultController.h
//  Pods
//
//  Created by atwork on 4/5/15.
//
//

#import <Foundation/Foundation.h>

@class SKYRecord;

/**
 An <SKYRecordResultController> is used for efficient access of <SKYRecord>s
 that are the result of a query operation.
 */
@interface SKYRecordResultController : NSObject

/**
 The number of records contained in the result.
 */
@property (nonatomic, readonly) NSUInteger numberOfRecords;

/**
 Returns a record at the specified index path.
 */
- (SKYRecord *)recordAtIndexPath:(NSIndexPath *)indexPath;

@end
