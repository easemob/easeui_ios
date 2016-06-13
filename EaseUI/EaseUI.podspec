Pod::Spec.new do |spec|
spec.name         = 'EaseUI'
spec.version      = '3.1.2'
spec.license      = { :type => 'MIT', :file => 'LICENSE' }
spec.summary      = 'EaseMob UI Kit'
spec.homepage     = 'https://github.com/easemob/easeui_ios'
spec.author       = {'EaseMob Inc.' => 'admin@easemob.com'}
spec.source       =  {:git => 'https://github.com/easemob/easeui_ios.git', :branch => 'new_dev', :tag => spec.version.to_s }
spec.source_files = 'EaseUI/**/*.{h,m,mm}'
spec.platform     = :ios, '6.0'
spec.vendored_libraries = ['EaseUI/EMUIKit/3rdparty/DeviceHelper/VoiceConvert/opencore-amrnb/libopencore-amrnb.a','EaseUI/EMUIKit/3rdparty/DeviceHelper/VoiceConvert/opencore-amrwb/libopencore-amrwb.a']
spec.requires_arc = true
spec.resource     = 'export/resources/EaseUIResource.bundle'
spec.xcconfig     = {'OTHER_LDFLAGS' => '-ObjC'}
end