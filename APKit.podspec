#
# Be sure to run `pod lib lint APKit.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'APKit'
  s.version          = '0.3.2'
  s.summary          = 'APKit, easy for use in app purchase.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
Use APKit for In-app purchase easier, set observer then click product, wait ... Wow, completed!
                       DESC

  s.homepage         = 'https://github.com/WildDylan/APKit'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Dylan' => 'dylan@china.com' }
  s.source           = { :git => 'https://github.com/WildDylan/APKit.git', :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/dylanccccc'

  s.ios.deployment_target = '7.1'

  s.source_files = 'APKit/Classes/**/*'

  s.public_header_files = 'APKit/Classes/**/*.h'
  s.frameworks = 'UIKit', 'StoreKit', 'Foundation'
end
