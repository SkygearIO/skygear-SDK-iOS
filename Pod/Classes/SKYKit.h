//
//  SKYKit.h
//  SKYKit
//
//  Copyright 2015 Oursky Ltd.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

#import "SKYAPSNotificationInfo.h"
#import "SKYAccessControl.h"
#import "SKYAccessToken.h"
#import "SKYAddRelationsOperation.h"
#import "SKYAsset.h"
#import "SKYChangePasswordOperation.h"
#import "SKYContainer.h"
#import "SKYContainer_Private.h"
#import "SKYDataSerialization.h"
#import "SKYDatabase.h"
#import "SKYDatabaseOperation.h"
#import "SKYDatabase_Private.h"
#import "SKYDefineAdminRolesOperation.h"
#import "SKYDefineCreationAccessOperation.h"
#import "SKYDeleteRecordsOperation.h"
#import "SKYDeleteSubscriptionsOperation.h"
#import "SKYDownloadAssetOperation.h"
#import "SKYError.h"
#import "SKYErrorCreator.h"
#import "SKYFetchRecordsOperation.h"
#import "SKYFetchSubscriptionsOperation.h"
#import "SKYGCMNotificationInfo.h"
#import "SKYGetAssetPostRequestOperation.h"
#import "SKYGetCurrentUserOperation.h"
#import "SKYLambdaOperation.h"
#import "SKYLocationSortDescriptor.h"
#import "SKYLoginUserOperation.h"
#import "SKYLogoutUserOperation.h"
#import "SKYModifyRecordsOperation.h"
#import "SKYModifySubscriptionsOperation.h"
#import "SKYNotification.h"
#import "SKYNotificationID.h"
#import "SKYNotificationInfo.h"
#import "SKYNotificationInfoDeserializer.h"
#import "SKYNotificationInfoSerializer.h"
#import "SKYOperation.h"
#import "SKYPostAssetOperation.h"
#import "SKYPubsub.h"
#import "SKYQuery.h"
#import "SKYQueryCursor.h"
#import "SKYQueryDeserializer.h"
#import "SKYQueryOperation.h"
#import "SKYQuerySerializer.h"
#import "SKYRecord.h"
#import "SKYRecordDeserializer.h"
#import "SKYRecordID.h"
#import "SKYRecordSerialization.h"
#import "SKYRecordSerializer.h"
#import "SKYRecordStorage.h"
#import "SKYRecordStorageCoordinator.h"
#import "SKYRecord_Private.h"
#import "SKYReference.h"
#import "SKYRegisterDeviceOperation.h"
#import "SKYRelation.h"
#import "SKYRelationPredicate.h"
#import "SKYRemoveRelationsOperation.h"
#import "SKYRequest.h"
#import "SKYResponse.h"
#import "SKYResultArrayResponse.h"
#import "SKYRole.h"
#import "SKYSendPushNotificationOperation.h"
#import "SKYSequence.h"
#import "SKYSetUserDefaultRoleOperation.h"
#import "SKYSignupUserOperation.h"
#import "SKYSubscription.h"
#import "SKYSubscriptionDeserializer.h"
#import "SKYSubscriptionSerialization.h"
#import "SKYSubscriptionSerializer.h"
#import "SKYUpdateUserOperation.h"
#import "SKYUploadAssetOperation.h"
#import "SKYUser.h"
#import "SKYUserDeserializer.h"
#import "SKYUserDiscoverPredicate.h"

#import "NSError+SKYError.h"
#import "NSURLRequest+SKYRequest.h"
#import "SKYQueryOperation+QueryUser.h"