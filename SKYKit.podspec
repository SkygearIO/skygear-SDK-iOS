Pod::Spec.new do |s|
  s.name             = "SKYKit"
  s.version          = "0.1.0"
  s.summary          = "iOS SDK for Skygear"
  s.description      = <<-DESC
                       This is the client library for Skygear backend.
                       DESC
  s.homepage         = "https://github.com/oursky/skygear-SDK-iOS"
  s.license          = 'Apache License, Version 2.0'
  s.author           = { "Oursky Ltd." => "hello@oursky.com" }
  s.source           = { :git => "https://github.com/oursky/skygear-iOS-SDK.git", :tag => s.version.to_s }

  s.platform     = :ios, '7.0'
  s.requires_arc = true

  s.source_files = 'Pod/Classes/**/*'
  s.resource_bundles = {
    'SKYKit' => ['Pod/Assets/*.png']
  }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  s.dependency 'FMDB', '~> 2.5'
  s.dependency 'SocketRocket', '~> 0.4'
end
