source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '13.0'
project 'Archive.xcodeproj'
inhibit_all_warnings!
use_frameworks!

def pods
  pod 'RxSwift'
  pod 'RxCocoa'
  pod 'RxFlow'
  pod 'RxDataSources', '~> 5.0'
  pod 'ReactorKit'
  pod 'Moya'
  pod 'Moya/RxSwift'
  pod 'SwiftGen'
  pod 'SwiftyJSON', '~> 4.0'
  pod 'Kingfisher', '~> 7.0'
  pod 'SnapKit', '~> 5.0.0'
  pod 'GrowingTextView', '0.7.2'
  pod 'CropViewController'
  pod 'UIImageColors'
  pod 'lottie-ios'
  pod 'SwiftLint'
  pod 'SwiftyTimer'
  
  pod 'KakaoSDKCommon'
  pod 'KakaoSDKAuth'
  pod 'KakaoSDKUser'
end

target 'Archive' do
  pods
end

post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '13.0'
            config.build_settings['EXCLUDED_ARCHS[sdk=iphonesimulator*]'] = 'arm64'
        end
    end
end
