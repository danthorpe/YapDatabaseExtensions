Pod::Spec.new do |s|
  s.name              = "YapDatabaseExtensions"
  s.version           = "1.0.0"
  s.summary           = "Helpers for using value types with YapDatabase."
  s.description       = <<-DESC
  
  Defines protocols and APIs via Swift extensions to allow for struct
  and enum types to be used & stored within YapDatabse.

                       DESC
  s.homepage          = "https://github.com/danthorpe/YapDatabaseExtensions"
  s.license           = 'MIT'
  s.author            = { "Daniel Thorpe" => "@danthorpe" }
  s.source            = { :git => "https://github.com/danthorpe/YapDatabaseExtensions.git", :tag => s.version.to_s }
  s.module_name       = 'YapDatabaseExtensions'
  s.social_media_url  = 'https://twitter.com/danthorpe'
  s.requires_arc      = true
  s.ios.deployment_target = '8.0'
  s.osx.deployment_target = '10.10'

  s.dependency 'YapDatabase', '~> 2.6'
  
  s.default_subspec   = 'Common' 

  s.subspec 'Common' do |ss|
    ss.source_files   = 'Pod/Common/*.swift'    
  end

  s.subspec 'PromiseKit' do |ss|
    ss.source_files   = 'Pod/PromiseKit/*.swift'
    ss.dependency 'YapDatabaseExtensions/Common'
    ss.dependency 'PromiseKit/Swift/Promise', '~> 1.5'
  end

  s.subspec 'BrightFutures' do |ss|
    ss.source_files   = 'Pod/BrightFutures/*.swift'
    ss.dependency 'YapDatabaseExtensions/Common'
    ss.dependency 'BrightFutures', '~> 1.0.0-beta'
  end

  s.subspec 'SwiftTask' do |ss|
    ss.source_files   = 'Pod/SwiftTask/*.swift'
    ss.dependency 'YapDatabaseExtensions/Common'
    ss.dependency 'SwiftTask', '~> 3.0'
  end

  s.subspec 'All' do |ss|
    ss.dependency 'YapDatabaseExtensions/PromiseKit'
    ss.dependency 'YapDatabaseExtensions/BrightFutures'
    ss.dependency 'YapDatabaseExtensions/SwiftTask'    
  end
end

