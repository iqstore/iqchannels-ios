#
# Be sure to run `pod lib lint IQChannels.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'IQChannels'
  s.version          = '1.0.0'
  s.summary          = 'IQChannels SDK'
  s.description      = <<-DESC
IQChannels iOS SDK
                       DESC

  s.homepage         = 'https://github.com/iqstore/iqchannels-ios'
  s.author           = { 'Ivan Korobkov' => 'i.korobkov@iqstore.ru' }
  s.source           = { :git => 'https://github.com/iqstore/iqchannels-ios.git', :tag => s.version.to_s }

  s.platform = :ios, '8.0'
  s.ios.deployment_target = '8.0'
  s.resources = 'ios/Classes/UI/*.{xib}'
  s.source_files = 'ios/Classes/**/*.{h,m}'
  s.requires_arc = true

  s.dependency 'JSQMessagesViewController', '~> 7.3'
  s.dependency 'SDWebImage', '~>3.8'
  s.dependency 'TRVSEventSource', '0.0.8'
end
