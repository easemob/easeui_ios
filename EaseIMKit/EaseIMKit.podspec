Pod::Spec.new do |s|
  s.name = 'EaseIMKit'
  s.version = '1.0.0'

  s.ios.deployment_target = '11.0'

  s.license = 'MIT'
  s.summary = 'easemob im sdk UIKit'
  s.homepage = 'http://docs-im.easemob.com/im/ios/other/easeimkit'
  s.description = <<-DESC
                    EaseIMKit Supported features:
                    1. Conversation list
                    2. Chat page (singleChat,groupChat,chatRoom)
                    3. Contact list
                  DESC
  s.author = { 'easemob' => 'dev@easemob.com' }
  s.source       = {:http => 'https://downloadsdk.easemob.com/downloads/EaseKit/EaseIMKit_1.0.0.zip' }
  
  s.xcconfig     = {'OTHER_LDFLAGS' => '-ObjC'}
  
  s.requires_arc = true
  
  s.static_framework = false
  s.frameworks = 'UIKit'
  s.libraries = 'stdc++'
  s.dependency 'Hyphenate'
  s.dependency 'Masonry'
  s.dependency 'MBProgressHUD'
  s.dependency 'FLAnimatedImage'
  s.dependency 'EMVoiceConvert'
  s.dependency 'SDWebImage'
  
end
