
Pod::Spec.new do |s|

  s.name         = "DYPageScrollView"
  s.version      = "1.0.0"
  s.summary      = "标题滚动，自带各种风格的效果"

  s.homepage     = "https://github.com/windDyl/DYPageScrollView"

  s.license      = "MIT"

  s.author             = { "windDyl" => "ldy2260479085@163.com" }
  
	s.platform     = :ios, "9.0"

  s.source       = { :git => "https://github.com/windDyl/DYPageScrollView.git", :tag => "1.0.0" }


  s.source_files  = "DYPageScrollView/DYPageView/*.swift"

end
