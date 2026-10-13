#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint sms_mms.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'sms_mms'
  s.version          = '0.1.0'
  s.summary          = 'Opens the native messaging app with SMS or MMS content.'
  s.description      = <<-DESC
Opens the native messaging app with recipients, a message and attachments filled in.
                       DESC
  s.homepage         = 'https://github.com/Manveer1999/flutter_sms_mms'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Manveer Singh' => '64741771+Manveer1999@users.noreply.github.com' }
  s.source           = { :path => '.' }
  s.source_files = 'sms_mms/Sources/sms_mms/**/*.swift'
  s.resource_bundles = {'sms_mms_privacy' => ['sms_mms/Sources/sms_mms/PrivacyInfo.xcprivacy']}
  s.dependency 'Flutter'
  s.platform = :ios, '13.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'
end
