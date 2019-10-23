#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#
Pod::Spec.new do |s|
  s.name             = 'flutter_sobot'
  s.version          = '0.0.1'
  s.summary          = '智齿客服flutter'
  s.description      = <<-DESC
智齿客服flutter
                       DESC
  s.homepage         = 'http://example.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Company' => 'email@example.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*','SobotLib/include/*'
  s.public_header_files = 'Classes/**/*.h'
  s.dependency 'Flutter'
  s.frameworks = 'AVFoundation', 'AssetsLibrary', 'AudioToolbox', 'SystemConfiguration', 'MobileCoreServices', 'webkit'
  s.library = 'z'
  s.vendored_frameworks = 'framework/SobotKit.framework'
  s.resource = 'framework/SobotKit.bundle'
  s.vendored_libraries='SobotLib/libSobotLib.a'
  s.ios.deployment_target = '8.0'
end

