Pod::Spec.new do |s|
  s.name = 'EaseIMKit'
  s.version = '0.0.1'

  s.ios.deployment_target = '11.0'

  s.license = 'MIT'
  s.summary = 'easemob im sdk UIKit'
  s.homepage = 'https://github.com/dujiepeng/EaseIMKit'
  s.description = <<-DESC
                    EaseIMKit Supported features:
                    1. Conversation list
                    2. Chat page (singleChat,groupChat,chatRoom)
                    3. Contact list
                  DESC
  s.author = { 'easemob' => 'dev@easemob.com' }
  s.source = { :git => 'https://github.com/dujiepeng/EaseIMKit.git',
               :tag => s.version.to_s,
               :submodules => true
  }
  
  s.xcconfig     = {'OTHER_LDFLAGS' => '-ObjC'}
  
  s.requires_arc = true
  s.resource_bundles = {
    'EaseIMKit' => ['EaseIMKit/**/*.{png,jpg,jpeg,gif}']
  }
  
  
#  s.static_framework = false
  s.frameworks = 'UIKit'
  s.libraries = 'stdc++'
  s.dependency 'Hyphenate'
  s.dependency 'Masonry'
  s.dependency 'MBProgressHUD'
  s.dependency 'FLAnimatedImage'
  s.dependency 'EMVoiceConvert'
  s.dependency 'SDWebImage'
  
end
