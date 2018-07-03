
Pod::Spec.new do |s|

  s.name         = "CJRollingAdView"
  s.version      = "1.0.0"
  s.summary      = "Vertical scrolling advertising."
  s.homepage     = "https://github.com/dreamCC/CJRollingAdView"


  s.license      = "MIT"
  s.author       = { "dreamCC" => "568644031@qq.com" }

  s.platform     = :ios, "8.0"
  s.source       = { :git => "https://github.com/dreamCC/CJRollingAdView.git", :tag => s.version }

  s.source_files  = "CJRollingAdView"
  s.requires_arc = true
end
