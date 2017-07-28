![Skygear Logo](.github/skygear-logo.png)

# Skygear SDK for iOS

[![CocoaPods](https://img.shields.io/cocoapods/v/SKYKit.svg)](http://cocoadocs.org/docsets/SKYKit)
[![CocoaPods](https://img.shields.io/cocoapods/dt/SKYKit.svg)](https://cocoapods.org/pods/SKYKit)
[![Build Status](https://travis-ci.org/SkygearIO/skygear-SDK-iOS.svg?branch=master)](https://travis-ci.org/SkygearIO/skygear-SDK-iOS)
[![License](https://img.shields.io/cocoapods/l/SKYKit.svg)](http://cocoadocs.org/docsets/SKYKit)


Skygear Server is a cloud backend for making web and mobile app development easier. [https://skygear.io](https://skygear.io)


The SKYKit (Skygear iOS SDK) library that gives you access to the Skygear Server from your iOS app.


## Getting Started

To get started, you need to have the [Skygear Server](https://github.com/skygearIO/skygear-server) running and iOS SDK installed into your app. You can see detailed procedure at the getting started guide at [https://docs.skygear.io/guides/intro/quickstart/ios/](https://docs.skygear.io/guides/intro/quickstart/ios/).

You can sign up the Skygear Hosting at the Skygear Developer Portal at [https://portal.skygear.io](https://portal.skygear.io)

# Installation with CocoaPods

You can install SKYKit via CocoaPods, first you need to install CocoaPods

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

Podspec 'SKYKit' include everything you are required to interact with Skygear,
that includes functionalities, like Facebook login and Forgot password.
If you want to make the dependency slimmer, you can use the `SKYKit/Core` subspec.


```
# Install everything
pod `SKYKit`

# Only install the core functionality
pod `SKYKit/Core`

# You can pick which options do you want
pod `SKYKit/Facebook`
pod `SKYKit/ForgotPassword`
```

Then, run the following command:

```
$ pod install
```

For more detail and other installation guides, please refer to our [Get Started Guide](https://docs.skygear.io/guides/intro/quickstart/ios/) at the Skygear [docs site](https://docs.skygear.io).


## Documentation
The full documentation for Skygear is available on our docs site. The [iOS SDK get started guide](https://docs.skygear.io/guides/intro/quickstart/ios/) is a good place to get started.


## Support

For implementation related questions or technical support, please refer to the [Stack Overflow](http://stackoverflow.com/questions/tagged/skygear) community.

If you believe you've found an issue with Skygear iOS SDK, please feel free to [report an issue](https://github.com/SkygearIO/skygear-SDK-iOS/issues).


## How to contribute

Pull Requests Welcome!

We really want to see Skygear grows and thrives in the open source community.
If you have any fixes or suggestions, simply send us a pull request!


## License & Copyright

```
Copyright (c) 2015-present, Oursky Ltd.
All rights reserved.

This source code is licensed under the Apache License version 2.0
found in the LICENSE file in the root directory of this source tree.
An additional grant of patent rights can be found in the PATENTS
file in the same directory.

```
