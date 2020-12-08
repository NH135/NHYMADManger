#
#  Be sure to run `pod spec lint NHYMADManger.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see https://guides.cocoapods.org/syntax/podspec.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |spec|

  # ―――  Spec Metadata  ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  These will help people to find your library, and whilst it
  #  can feel like a chore to fill in it's definitely to your advantage. The
  #  summary should be tweet-length, and the description more in depth.
  #

  spec.name         = "NHYMADManger"
  spec.version      = "1.0.1"
  spec.summary      = "test"
  spec.homepage     = "https://github.com/NH135/NHYMADManger"
  spec.license      = "MIT"
   spec.author             = { "牛辉" => "240714015@qq.com" }
   spec.platform     = :ios, "9.0"
  spec.source       = { :git => "https://github.com/NH135/NHYMADManger.git", :tag => "#{spec.version}" }
 
spec.public_header_files = "NHYMADManger/YMADManger.h"
spec.dependency "AFNetworking", "~> 3.2.1"
# spec.dependency "YMSigmobManager"
# spec.dependency "GDTSDKD" 
 
  spec.source_files  = "NHYMADManger/**/*"
spec.requires_arc  = true
  
end
