Pod::Spec.new do |s|
  s.name = 'EaseIMKit'
  s.version = '0.0.1'

  s.ios.deployment_target = '11.0'

  
  s.license = 'MIT'
  s.summary = 'easemob im sdk UIKit'
  s.homepage = 'https://github.com/dujiepeng/EaseIMKit'
  s.author = { 'easemob' => 'dev@easemob.com' }
  s.source = { :git => 'https://github.com/dujiepeng/EaseIMKit.git',
               :tag => s.version.to_s,
               :submodules => true
  }
  
  s.description = 'easemob sdk ui kit'
  s.requires_arc = true
  s.source_files = 'EaseIMKit/**/*.{h,m,mm}'
  s.resource_bundles = {
    'EaseIMKit' => ['EaseIMKit/**/**/*.{png,jpg,jpeg,gif}']
  }
  
  s.libraries = 'stdc++'
  s.dependency 'Hyphenate', '~> 3.7.2'
  s.dependency 'Masonry'
  s.dependency 'MJRefresh'
  s.dependency 'MWPhotoBrowser'
  s.dependency 'MBProgressHUD'
  s.dependency 'FLAnimatedImage'
  s.dependency 'EMVoiceConvert'
  
end
