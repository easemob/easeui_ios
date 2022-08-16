Pod::Spec.new do |s|
    s.name             = 'EaseIMKit'
    s.version          = '3.9.5.1'
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
    s.source = { :git => 'https://github.com/easemob/easeui_ios.git', :tag => 'EaseIMKit_3.9.5.1'}
    s.frameworks = 'UIKit'
    s.libraries = 'stdc++'
    s.ios.deployment_target = '10.0'
    s.source_files = [
        'EaseIMKit/EaseIMKit/EaseIMKit.h',
        'EaseIMKit/EaseIMKit/EasePublicHeaders.h',
        'EaseIMKit/EaseIMKit/**/*.{h,m,mm}'
    ]
    s.public_header_files = [
        'EaseIMKit/EaseIMKit/**/*.h',
    ]
    
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
    s.dependency 'Masonry'
#    s.dependency 'SDWebImage'

end
