Pod::Spec.new do |s|
    s.name             = 'EaseIMKit'
    s.version          = '3.8.9'
    s.summary = 'easemob im sdk UIKit'
    s.homepage = 'http://docs-im.easemob.com/im/ios/other/easeimkit'
    s.description = <<-DESC
                    EaseIMKit Supported features:

                    1. Conversation list
                    2. Chat page (singleChat,groupChat,chatRoom)
                    3. Contact list
                  DESC
    s.license          = { :type => 'MIT', :file => 'LICENSE' }
    s.author           = { 'easemob' => 'dev@easemob.com' }
    s.source = { :git => 'https://github.com/easemob/easeui_ios.git', :tag => 'EaseIMKit_3.8.9'}
    #s.source = { :git => 'https://github.com/MThrone/easeui_ios.git', :tag => 'EaseIMKit_3.8.4'}
    s.frameworks = 'UIKit'
    s.libraries = 'stdc++'
    s.ios.deployment_target = '10.0'
    s.source_files = [
        'EaseIMKit/EaseIMKit/EaseIMKit.h',
        'EaseIMKit/EaseIMKit/EasePublicHeaders.h',
        'EaseIMKit/EaseIMKit/**/*.{h,m,mm}'
    ]
    
    s.subspec 'Category' do |ss|
      ss.source_files = "EaseIMKit/EaseIMKit/Category/*.{h,m}"
    end
    
    s.subspec 'Classes' do |ss|
      ss.source_files = "EaseIMKit/EaseIMKit/Classes/**/*.{h,m}"
    end
    
    s.static_framework = true
    s.resource = 'EaseIMKit/EaseIMKit/Resources/EaseIMKit.bundle'
    #s.resources = ['Images/*.png', 'Sounds/*']
    
    #s.ios.resource_bundle = { 'EaseIMKit' => 'EaseIMKit/EaseIMKit/Assets/*.png' }
    #s.resource_bundles = {
     # 'EaseIMKit' => ['EaseIMKit/EaseIMKit/Assets/*.png']
    #}
    s.pod_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64',
                              'VALID_ARCHS' => 'arm64 armv7 x86_64'
                            }
    s.user_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64' }

    s.dependency 'HyphenateChat'
    s.dependency 'EMVoiceConvert', '0.1.0'


end
