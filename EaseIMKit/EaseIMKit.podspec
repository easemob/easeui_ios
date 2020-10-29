Pod::Spec.new do |s|
  s.name = 'EaseIMKit'
  s.version = '0.0.1'

  s.ios.deployment_target = '9.0'


  s.license = 'MIT'
  s.summary = 'easemob im sdk UIKit'
  s.homepage = 'https://github.com/dujiepeng/EaseIMKit'
  s.author = { 'easemob' => 'dev@easemob.com' }
  s.source = { :git => 'https://github.com/dujiepeng/EaseIMKit.git', :tag => s.version.to_s }

  s.description = 'easemob sdk ui kit'

  s.requires_arc = true

  s.source_files = 'EaseIMKit/*/*.{h,m}', 'EaseIMKit/EaseIMKit.h'
  
end
