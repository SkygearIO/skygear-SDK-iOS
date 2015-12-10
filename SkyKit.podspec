#
# Be sure to run `pod lib lint SkyKit.podspec' to ensure this is a
# valid spec and remove all comments before submitting the spec.
#
# Any lines starting with a # are optional, but encouraged
#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "SkyKit"
  s.version          = "0.1.0"
  s.summary          = "Ourd Objective-C client library."
  s.description      = <<-DESC
                       This client library connects to the Ourd backend.
                       DESC
  s.homepage         = "https://github.com/oursky/ODKit"
  # s.screenshots     = "www.example.com/screenshots_1", "www.example.com/screenshots_2"
  s.license          = 'Apache License, Version 2.0'
  s.author           = { "Kwok-kuen Cheung" => "cheungpat@y03.hk" }
  s.source           = { :git => "https://github.com/oursky/ODKit.git", :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/oursky'

  s.platform     = :ios, '7.0'
  s.requires_arc = true

  s.source_files = 'Pod/Classes/**/*'
  s.resource_bundles = {
    'SkyKit' => ['Pod/Assets/*.png']
  }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.4'
  s.dependency 'FMDB', '~> 2.5'
  s.dependency 'SocketRocket', '~> 0.4'
end
