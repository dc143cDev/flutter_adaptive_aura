#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint adaptive_aura.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'adaptive_aura'
  s.version          = '0.0.1'
  s.summary          = 'Apple Music style album cover interaction.'
  s.description      = <<-DESC
A Flutter package that provides Apple Music style album cover interaction with color extraction and responsive UI.
                       DESC
  s.homepage         = 'http://example.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Company' => 'email@example.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.platform = :ios, '12.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'
end 