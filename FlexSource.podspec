
Pod::Spec.new do |s|
  s.name         = "FlexSource"
  s.version      = "0.0.22"
  s.summary      = "Dynamic web extraction framework"
  s.description  = <<-DESC
FlexSource is web extraction framework for mobile (iOS) applications. One can decouple information extraction method from the Internet via XML rules that mobile application can stream when starting app (or on some other time point/event).                    
                   DESC
  s.homepage     = "http://galic-design.com"
  s.screenshots  = "http://galic-design.com/flexSourceTests/shot.png"
  s.license      = 'MIT'
  s.author       = { "Ivo Galic" => "info@galic-design.com" }
  s.source       = { :git => "https://github.com/galic1987/FlexSource.git", :tag => s.version.to_s }

  s.platform     = :ios
  
  # s.ios.deployment_target = '5.0'
  # s.osx.deployment_target = '10.7'
  
  s.requires_arc = true

  s.source_files = 'FlexSource'
  #s.resources = 'FlexSource'
  s.library      = 'xml2'
  s.xcconfig = { 'HEADER_SEARCH_PATHS' => '$(SDKROOT)/usr/include/libxml2' }

  #s.ios.exclude_files = 'Classes/osx'
  #s.osx.exclude_files = 'Classes/ios'
  s.frameworks = 'UIKit'
  s.prefix_header_contents = %(
// =========== A ==========
#ifdef __OBJC__
    #import <Foundation/Foundation.h>
#ifdef DEBUG
#   define DLog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)
#else
#   define DLog(...)
#endif
#endif)
  
end
