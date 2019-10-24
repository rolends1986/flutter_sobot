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
  s.source_files = 'Classes/**/*'  #,'SobotKit/**/*.{h,m,a}'
  s.public_header_files = 'Classes/**/*.h'
  s.dependency 'Flutter'
  s.frameworks = 'AVFoundation', 'AssetsLibrary', 'AudioToolbox', 'SystemConfiguration', 'MobileCoreServices', 'webkit'
  s.library = 'z.1.2.5'
  s.vendored_frameworks = 'SobotKit.framework'
  s.resource = "SobotKit.bundle"
#  s.resource_bundles = {
#    'SobotKit' => ['SobotKit_bundle/**/*.{png,lproj}'],
#  }
  s.xcconfig = {  "OTHER_LDFLAGS" => "$(inherited) -licucore"}
  #s.vendored_libraries='SobotKit/SobotLib/libSobotLib.a'
  #s.prefix_header_file = 'flutter_sobot-prefix.pch'
  s.ios.deployment_target = '8.0'
end

