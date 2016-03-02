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
