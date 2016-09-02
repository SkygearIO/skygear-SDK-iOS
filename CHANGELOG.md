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
