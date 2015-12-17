Pod::Spec.new do |s|
  s.name             = "SKYKit"
  s.version          = "0.1.0"
  s.summary          = "iOS SDK for Skygear"
  s.description      = <<-DESC
                       This is the client library for Skygear backend.
                       DESC
  s.homepage         = "https://github.com/SkygearIO/skygear-SDK-iOS"
  s.license          = 'Apache License, Version 2.0'
  s.author           = { "Oursky Ltd." => "hello@oursky.com" }
  s.source           = { :git => "https://github.com/SkygearIO/skygear-SDK-iOS.git", :tag => s.version.to_s }

  s.platform     = :ios, '7.0'

  s.default_subspec = 'Core'

  s.subspec 'Core' do |core|
    core.requires_arc = true

    core.source_files = 'Pod/Classes/**/*'
    core.resource_bundles = {
      'SKYKit' => ['Pod/Assets/*.png']
    }

    # core.public_header_files = 'Pod/Classes/**/*.h'
    # core.frameworks = 'UIKit', 'MapKit'
    core.dependency 'FMDB', '~> 2.5'
    core.dependency 'SocketRocket', '~> 0.4'
  end

  s.subspec 'Facebook' do |facebook|
    facebook.source_files = 'Pod/Extensions/Facebook/**/*.{h,m}'
    facebook.requires_arc = true

    facebook.dependency 'FBSDKCoreKit', '~> 4.0'
  end
end
