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

@property (nonatomic, readwrite) ODRecordChangeState state;
@property (nonatomic, readwrite) NSError *error;
@property (nonatomic, readwrite, copy) void (^completionBlock)();

- (instancetype)initWithRecord:(ODRecord *)record
                        action:(ODRecordChangeAction)action
                 resolveMethod:(ODRecordResolveMethod)resolveMethod
              attributesToSave:(NSDictionary *)attributesToSave;

@end
