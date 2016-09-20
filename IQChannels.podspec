#
# Be sure to run `pod lib lint IQChannels.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'IQChannels'
  s.version          = '0.1.0'
  s.summary          = 'IQChannels SDK'
  s.description      = <<-DESC
IQChannels iOS SDK
                       DESC

  s.homepage         = 'https://github.com/iqstore/iqchannels-ios'
  s.author           = { 'Ivan Korobkov' => 'ivan.korobkov@bigdev.ru' }
  s.source           = { :git => 'https://github.com/iqstore/iqchannels-ios.git', :tag => s.version.to_s }
  s.ios.deployment_target = '8.0'
  s.source_files = 'iqchannels-ios/Classes/**/*'

  s.dependency 'TRVSEventSource', '0.0.8'
  s.dependency 'JSQMessagesViewController', '~> 7.3'

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
end
