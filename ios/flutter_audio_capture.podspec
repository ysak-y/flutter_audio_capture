#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint flutter_audio_capture.podspec' to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'flutter_audio_capture'
  s.version          = '1.1.4'
  s.summary          = 'audio stream capture for iOS and Android OS'
  s.description      = <<-DESC
                        audio stream capture for iOS and Android OS.
                       DESC
  s.homepage         = 'https://github.com/ysak-y'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Yoshiaki Yamada' => 'yoshiaki.0614@gmail.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.platform = :ios, '13.6'

  # Flutter.framework does not contain a i386 slice. Only x86_64 simulators are supported.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'VALID_ARCHS[sdk=iphonesimulator*]' => 'x86_64' }
  s.swift_version = '5.0'
end
