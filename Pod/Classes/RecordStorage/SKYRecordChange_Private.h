//
//  SKYRecordChange_Private.h
//  Pods
//
//  Created by atwork on 4/5/15.
//
//

#import "SKYRecordChange.h"

@class SKYRecord;

@interface SKYRecordChange ()

@property (nonatomic, readwrite, getter=isFinished) BOOL finished;
@property (nonatomic, readwrite) NSError *error;

@end
