# SKYKit

[![CocoaPods](https://img.shields.io/cocoapods/v/SKYKit.svg)](http://cocoadocs.org/docsets/SKYKit)
[![Build Status](https://travis-ci.org/SkygearIO/skygear-SDK-iOS.svg?branch=master)](https://travis-ci.org/SkygearIO/skygear-SDK-iOS)
[![License](https://img.shields.io/cocoapods/l/SKYKit.svg)](http://cocoadocs.org/docsets/SKYKit)

iOS SDK for Skygear


# Installation with CocoaPods

```
$ gem install cocoapods
```

To integrate SKYKit into your Xcode project using CocoaPods, specify it in your Podfile:

```
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '8.0'

pod 'SKYKit'
```

#### Subspec

Podspec 'SKYKit' include the core that you are required to interact with Skygear,
for optional funcationility, like Facebook login. You need to include the 
respective subspce.

For example, if you need facebook login, include the following

```
pod 'SKYKit/Facebook'
```

Then, run the following command:

```
$ pod install
```
