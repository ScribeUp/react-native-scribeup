require "json"

package = JSON.parse(File.read(File.join(__dir__, "package.json")))
# Read iOS SDK version with fallback
ios_sdk_version = package.dig("config", "nativeSDKVersions", "ios") || "0.5.7"

Pod::Spec.new do |s|
  s.name         = "RNScribeupSDK"
  s.version      = package["version"]
  s.summary      = package["description"]
  s.homepage     = package["homepage"]
  s.license      = package["license"]
  s.authors      = package["author"]

  s.platforms    = { :ios => min_ios_version_supported }
  s.source       = { :git => "https://github.com/ScribeUp/react-native-scribeup-sdk.git", :tag => s.version.to_s }

  s.source_files = "ios/**/*.{h,m,mm,cpp,swift}"
  s.private_header_files = "ios/**/*.h"

  s.dependency 'ScribeUpSDK', ios_sdk_version
  s.swift_version = '5.0'

  install_modules_dependencies(s)
end
