## 1.5.0 (2018-04-23)

### Features

- Implement request verification and submit code

### Bug Fixes

- Fix reset password expireAt parameter

### Other Notes

- Improve auth container response handling
- Pin lizard version because 1.14.9 cannot be installed
- Add typing to SKYRecord
- Move record storage to its own extension
- Add admin prefix to disable/enable user functions
- Return error if API endpoint is not configured
- Fix assorted compiler warnings

## 1.4.0 (2018-03-07)

### Features

- Support enable/disable user account

### Bug Fixes

- Serialise profile when signup

### Other Notes

- Update error code list
- Remove unnecessary config and parameters for SSO
- Improve travis script
- Fix xcpretty with travis exit code
- Support macOS app development and update iOS deployment target
- Expose SKYAccessControl constructor in public headers

## 1.3.1 (2018-01-16)

### Features

- Add open, close and error hook for pubsub (#155)

### Bug Fixes

- Fix unable to init SKYAsset (#169)

### Other Notes

- Add login with custom token example
## 1.3.0 (2018-01-04)

### Features

- Base64 decode result from url (#164)
- Add login with custom token #153
- OAuth web login and link flow (#127, #141)

### Other Notes

- Fix missing doc for subspec
- Fix clang-format
- Update travis osx_image to xcode9.2

## 1.2.0 (2017-12-11)

### Features

- Derive asset mimeType with MagicKit(#148)
- Register device token in login and signup success callback
- Support using NSDictionary as named arguments for callLambda (#89)

### Other Notes

- Fix swiftlint and update rules
- Fix clang-format

## 1.1.1 (2017-11-16)

### Bug Fixes

- Ensure all field types of SKYRecord conform NSCopying and NSCoding (#144)
- Derive asset mimeType with MagicKit (#133)
- Fix unable to print user_id in log upon sign up
- Handle lambda responds with null result

## 1.1.0 (2017-08-07)

### Incompatible Changes

- SKYRecord will replace SKYUser for representing user

  In previous version of SKYKit, authentication methods return a SKYUser
  which contains user-related information such as User ID, username and
  email. These information is moved to SKYRecord and the authentication methods
  are updated to return SKYRecord instead.

### Features

- New signup login, remove SKYUser object (#112)
- Add forgot password functions to SKYAuthContainer (#110, SkygearIO/features#70)

### Other Notes

- Upload doc prefixed with version to s3 bucket for CI
- Add nullability annotation to objective-c header files (#51)
- Update links to Get Started Guide in README

## 1.0.0 (2017-06-30)

### Incompatible Changes

- Update container API grouping (#104, SkygearIO/features#70)

### Bug Fixes

- Make accessControl property on SKYRecord readwrite

    The existing implementation does not work for newly create record
    because the access control property is initially null.

- Fix unable to upload asset (#100)

### Other Notes

- Update Swift Example to Swift 3.0 (#51)
- Make SKYAsset conforms with NSCopying (#103)

## 0.24.0 (2017-05-23)

### Features

- Add API for adding user profile after signing up

### Other Notes

- Fix broken link at README

## 0.23.0 (2017-04-20)

### Features

- Use server-based default ACL (SkygearIO/skygear-server#309)

### Other Notes

- Rename device registration methods (#76)

## 0.22.2 (2017-03-31)

### Features
- Read `content_type` for asset serialization (#79)
- Read content type in asset serialisation SkygearIO/skygear-SDK-JS#164

### Bug Fixes
- Wrap error messages with NSLocalizedString (#85)

### Other Notes
- Generate documentation using Jazzy


## 0.22.1 (2017-02-16)

### Bug Fixes

- Fix parsing User ID ACL without `relation: $direct`

## 0.22.0 (2017-02-10)

### Features

- Support for container request timeout (SkygearIO/skygear-server#271)

## 0.21.0 (2017-01-11)

### Features

- Support send push notification by topic (SkygearIO/skygear-server#239)


## 0.20.0 (2016-12-20)

### Features

- Support unregister device (SkygearIO/skygear-server#245, SkygearIO/skygear-server#249)
- Implement SKYUnknownValue (SkygearIO/skygear-server#231)

### Bug Fixes

- Prevent nil as dict value when deserializing (#71)
- Include url of asset on serialization (#64)
- Serialize NSDate consistently in UTC timezone
- Fix logout error handling
- Fix date serialization (SkygearIO/skygear-server#237)
- Fix API key not attached to lambda request (#55)

### Other Notes

- Remove Chat extension

    Use SKYKitChat instead: https://github.com/SkygearIO/skygear-SDK-iOS

- Add usage description for photos and cameras

    These are required in iOS 10.

- Use Xcode 8, XcodeBuild and new CocoaPods

    This is fix travis error due to Xcode 7 not compatible with
    FBSDKCoreKit.


## 0.19.0 (2016-11-10)

No change since last release


## 0.18.0 (2016-10-28)

### Features

- Persist current user information (#49)


## 0.17.0 (2016-09-15)

### Features

- Support last login and last seen at user object (SkygearIO/skygear-server#110)
- Add Chat extension

### Minor Fixes

- Expose `-[SKYNotification subscriptionID]` (#41)

### Other Notes

- For the chat extension, it will work together with chat plugin:
  https://github.com/SkygearIO/chat


## 0.16.0 (2016-09-02)

### Features

- Support new asset upload mechanism (SkygearIO/skygear-server#107)
- Add `whoami` API for querying and update currnetUser from server (SkygearIO/skygear-server#111)

### Bug Fixes

- Improve metadata handling in SKYRecord and SKYRecordStorage (#30, #36)
- SKYRecordStorage should set SKYRecord metadata fields when saving (#30)
- Make SKYSequence conform with NSCoding (#28)
- Reload table view in Example after saving

### Other Notes

- Specify deviceID when creating subscription operations (#23, #26)


## 0.15.0 (2016-08-17)

### Features

- Support user discovery with username (skygeario/skygear-server#90)

### Other Notes

- Remove SKYQueryUsersOperation


## 0.14.0 (2016-07-26)

### Features

- Add example app in Swift (#9)

### Bug fixes

- Fix request/response handling on asset operations (#5)
- Fix date serialization format (#15)
- Remove caching of device id in device-related operations (#12)

### Other notes

- Remove SKYPushOperation which never worked


## 0.13.0 (2016-07-05)

No change since last release


## 0.12.1 (2016-06-23)

### Incompatible Changes
- Update config address format

  Changed to use full url of endpoint in `- (void)configAddress:`,
  for example, `[container configAddress:@"https://endpoint.skygeario.com/"]`

### Bug fixes
- Fix crash when deleting one record with error
- Fix wrong data when sign up with username


## 0.12.0 (2016-05-30)

No change since last release


## 0.11.0 (2016-05-09)

### Other Notes
- Update slack notification token (SkygearIO/skygear-server#19)


## 0.10.1 (2016-04-14)

### Incompatible Changes
- API Changes for ACL modification (oursky/skygear-SDK-iOS#259)
  - Remove API for add / remove a specific ACL entry
  - Add API for directly set no access / read only / read write access.


## 0.10.0 (2016-04-13)

### Features
- Add support for public readable default ACL (oursky/skygear-SDK-iOS#259)


## 0.9.0 (2016-03-16)

### Other Notes

- Return `SKYRecord` when query users by emails #255

## 0.8.0 (2016-03-09)

### Other Notes

- Update endpoint and payload for set record creation access

## 0.7.0 (2016-03-02)

### Features

- Implement role-based ACL #245, #246, #247, #249
- Implement user roles and update user #248
- Implement SKYRole and related operations #244

## 0.6.0 (2016-02-24)

### Incompatible Changes

- Refactor `SKYUser` and `SKYUserRecordID`
  - Use `SKYUser` instead of `SKYUserRecordID`
  - Use `userID` property as an identifier of `SKYUser`

### Bug Fixes

- Fix passing operation error in SKYDatabase #241

## 0.5.0 (2016-02-17)

### Features

- Support for relation/discover in user record query #242

## 0.4.0 (2016-01-13)

### Feature

- Support for changing user password #177

### Bug Fixes

- Fix sqlite_int64 undefined in FMDB 2.6
- Fix SKYDeleteRecordsOperation completion block always receives empty array

## 0.3.0 (2016-01-06)

### Features

- Support for setting auto-increment field #218
- Allow application specified asset mime type #131

## 0.2.0 (2015-12-23)

### Features

- Simplify SKYOperation error handling #170

### Bug Fixes

- Fix lint errors with Facebook subspec #233

## 0.1.0 (2015-12-16)

### Features

- Add facebook-extension #216
