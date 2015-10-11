Pod::Spec.new do |s|
  s.name              = "YapDatabaseExtensions"
  s.version           = "2.0.1"
  s.summary           = "Helpers for using value types with YapDatabase."
  s.description       = <<-DESC
  
  Defines APIs to conveniently read, write and remove objects and values
  to or from YapDatabse. See ValueCoding for value type support.

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
  s.source_files      = 'YapDatabaseExtensions/Shared/*.swift'

  s.dependency 'ValueCoding', '~> 1'
  s.dependency 'YapDatabase', '~> 2'  
end

