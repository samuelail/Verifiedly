#
# Be sure to run `pod lib lint Verifiedly.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'Verifiedly'
  s.version          = '1.0.0'
  s.summary          = 'Identity verification and fraud prevention for fast growing startups'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = 'Verifiedly allows companies to embed identity verification and fraud prevention products in their applications'

  s.homepage         = 'https://github.com/Samuelail/Verifiedly'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Samuel Ailemen' => 'support@verified.ly' }
  s.source           = { :git => 'https://github.com/Samuelail/Verifiedly.git', :tag => s.version.to_s }
   s.social_media_url = 'https://twitter.com/verfiedly'

  s.ios.deployment_target = '10.0'
  s.swift_versions = ['4.0']

  s.source_files = 'Resources/*.swift'
  s.resources = 'Resources/**/*.{png,storyboard,json}'
  
   #s.resource_bundles = {
   #  'Verifiedly' => ['Verifiedly/Resources/*/**']
   #}

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  s.dependency 'ActiveLabel'
 s.dependency  'Alamofire'
 s.dependency  'SwiftyJSON'
 s.dependency 'RappleProgressHUD'
 s.dependency 'SwiftMessages'
 s.dependency 'SwiftPublicIP'
 s.dependency 'lottie-ios'
end
