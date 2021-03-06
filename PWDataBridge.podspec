
Pod::Spec.new do |s|


  s.name         = "PWDataBridge"
  s.version      = "0.0.20"
  s.summary      = "KVO数据封装"


  s.description  = "KVO数据封装"

  s.homepage     = "https://github.com/wnrz/PWDataBridge.git"

  s.license      = "MIT"

  s.author       = { "PW" => "66682060@qq.com" }


  s.platform     = :ios, "8.0"
  s.ios.deployment_target = "8.0"

  s.public_header_files = 'PWDataBridge/PWDataBridge/*.h'
  s.source_files = 'PWDataBridge/PWDataBridge/PWDataBridge.h'

  s.source = { :git => 'https://github.com/wnrz/PWDataBridge.git', :tag => s.version.to_s}
  

  s.requires_arc = true
  s.framework = "UIKit","Foundation"


  s.subspec 'PWDataBridge' do |ss|#
    ss.source_files = 'PWDataBridge/PWDataBridge/**/*.{h,m,c}'
    ss.ios.frameworks = 'UIKit', 'Foundation','UIKit'
  end

  s.resource_bundles = {'PWDataBridge' => ['PWDataBridge/PWDataBridge/**/*.{png,plist,xib}']}

#  s.pod_target_xcconfig = {
#      'CLANG_ALLOW_NON_MODULAR_INCLUDES_IN_FRAMEWORK_MODULES' => 'YES',
#      'FRAMEWORK_SEARCH_PATHS' => '$(inherited) ${PODS_ROOT}/**',
#      'LIBRARY_SEARCH_PATHS' => '$(inherited) ${PODS_ROOT}/**' ,
#      'OTHER_LDFLAGS'          => '$(inherited) -undefined dynamic_lookup',
#      "DEFINES_MODULE" => "YES"
#  }
  
#  s.static_framework = true
end
