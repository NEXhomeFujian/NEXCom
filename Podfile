# Uncomment the next line to define a global platform for your project
platform :ios, '9.0'   #运行平台和支持系统版本
source "https://gitlab.linphone.org/BC/public/podspec.git"  #linphone云对讲资源库
source "https://github.com/CocoaPods/Specs.git"   #官方资源库
source 'https://github.com/aliyun/aliyun-specs.git'  #阿里资源库

def linpod
  pod 'linphone-sdk', '~> 5.2.40'
end

def common
  linpod
  pod 'IQKeyboardManager', '~> 6.5.9'
  pod 'SnapKit', '~> 4.2.0'
  pod 'FMDB', '~> 2.7.5'
  pod 'AlicloudPush', '~> 1.9.9'
  pod 'Alamofire', '~> 4.9.1'
  pod 'CryptoKit', '~> 0.4.0'
  pod 'lottie-ios', '~> 3.2.3'
  
  pod 'NHFoundation',
  :path => 'LocalPods/nhfoundation-ios'
  
end

target 'NEXcom' do  #测试环境包
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!
  common
end

