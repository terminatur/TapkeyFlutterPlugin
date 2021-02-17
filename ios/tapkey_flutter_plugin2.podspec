#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint tapkey_flutter_plugin2.podspec' to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'tapkey_flutter_plugin2'
  s.version          = '0.0.1'
  s.summary          = 'A new Flutter plugin.'
  s.description      = <<-DESC
A new Flutter plugin.
                       DESC
  s.homepage         = 'http://example.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Company' => 'email@example.com' }
  s.source           = { :path => '.' }
#  s.source = { :git => 'https://github.com/tapkey/TapkeyCocoaPods', :tag=> '2.7.2.0' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.dependency 'witte-mobile-library', '1.0.0'
  s.dependency 'AppAuth'
  s.dependency 'TapkeyMobileLib', '2.7.2.0'
#  s.dependency 'TapkeyMobileLib', :git => 'https://github.com/tapkey/TapkeyCocoaPods', :tag=> '2.7.2.0'
#  s.dependency { :git => 'https://github.com/tapkey/TapkeyCocoaPods' }
  s.platform = :ios, '9.0'
  s.ios.deployment_target = '9.0'
  
#  s.subspec 'pAuth' do |auth|
#    auth.source = { :git => 'git://https://github.com/openid/AppAuth-iOS.git', :tag=> 'v1.3.0' }
#  end

  # Flutter.framework does not contain a i386 slice.
#  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
#  s.swift_version = '5.0'
end
