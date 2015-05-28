//
//  ODRecordChange_Private.h
//  Pods
//
//  Created by atwork on 4/5/15.
//
//

#import "ODRecordChange.h"

@class ODRecord;

@interface ODRecordChange ()

@property (nonatomic, readwrite, getter=isFinished) BOOL finished;
@property (nonatomic, readwrite) NSError *error;

@end
