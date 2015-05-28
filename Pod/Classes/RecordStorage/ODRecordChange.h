//
//  ODRecordChange.h
//  Pods
//
//  Created by atwork on 4/5/15.
//
//

#import <Foundation/Foundation.h>

@class ODRecord;
@class ODRecordID;

typedef enum : NSInteger {
    /**
     ODRecordStorage does not automatically resolve conflict,
     you have to check for failed changes and handle the error manually.
     */
    ODRecordResolveManually,
    
    /**
     ODRecordStorage will replace the remote record by saving with
     the local copy of the record, ignoring all existing attributes
     on remote.
     */
    ODRecordResolveByReplacing,
    
    /**
     ODRecordStorage will update the remote record by updating
     the remote copy with only the modified attributes.
     */
    ODRecordResolveByUpdatingDelta,
    
    /**
     ODRecordStorage will update the remote record if the modified
     attributes were not also modified on the remote.
     */
    ODRecordResolveByUpdatingDeltaIfNotModified,
} ODRecordResolveMethod;

typedef enum : NSInteger {
    ODRecordChangeSave,
    ODRecordChangeDelete,
} ODRecordChangeAction;

@interface ODRecordChange : NSObject <NSCoding>

@property (nonatomic, readonly, copy) ODRecordID *recordID;
@property (nonatomic, readonly, copy) NSDictionary *attributesToSave;
@property (nonatomic, readonly) ODRecordChangeAction action;
@property (nonatomic, readonly, getter=isFinished) BOOL finished;
@property (nonatomic, readonly) ODRecordResolveMethod resolveMethod;
@property (nonatomic, readonly, copy) NSError *error;

- (instancetype)initWithRecord:(ODRecord *)record
                        action:(ODRecordChangeAction)action
                 resolveMethod:(ODRecordResolveMethod)resolveMethod
              attributesToSave:(NSDictionary *)attributesToSave;

- (instancetype)initWithRecordID:(ODRecordID *)recordID
                          action:(ODRecordChangeAction)action
                   resolveMethod:(ODRecordResolveMethod)resolveMethod
                attributesToSave:(NSDictionary *)attributesToSave;

@end
