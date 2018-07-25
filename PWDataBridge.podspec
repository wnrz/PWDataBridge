
Pod::Spec.new do |s|


  s.name         = "PWDataBridge"
  s.version      = "0.0.1"
  s.summary      = "KVO数据封装"


  s.description  = "KVO数据封装"

  s.homepage     = "https://github.com/wnrz/PWDataBridge.git"

  s.license      = "MIT"

  s.author       = { "PW" => "66682060@qq.com" }


  s.platform     = :ios, "8.0"
  s.ios.deployment_target = "8.0"


  #s.source       = { :git => "../"}
  s.public_header_files = 'PWDataBridge/PWDataBridge/*.h'#公共的头文件地址
  s.source_files = 'PWDataBridge/PWDataBridge/PWDataBridge.h'#文件地址，pod会以这个地址下载需要的文件构建pods

  s.source = { :git => 'https://github.com/wnrz/PWDataBridge.git', :tag => s.version.to_s}
  #s.ios.vendored_frameworks ='release/0.0.1/PWUIKit.framework'

  s.requires_arc = true
  s.framework = "UIKit","Foundation"


  s.subspec 'HomeDataProject' do |ss|#
    ss.source_files = 'HomeDataProject/HomeDataProject/**/*.{h,m,c}'
    ss.ios.frameworks = 'UIKit', 'Foundation','UIKit'
  end

  s.resource_bundles = {'HomeDataProject' => ['HomeDataProject/HomeDataProject/**/*.{png,plist,xib}']}

  s.dependency 'BaseBusiness'
  s.dependency 'BaseUtils'
  s.dependency 'BaseUIKit'
end
