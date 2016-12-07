Pod::Spec.new do |s|
  s.name              = "YapDatabaseExtensions"
  s.version           = "2.6.0"
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
  s.default_subspec   = 'Persitable'
  s.ios.deployment_target = '8.0'
  s.osx.deployment_target = '10.10'

  s.dependency 'ValueCoding', '~> 1.5'
  s.dependency 'YapDatabase', '2.9.2'
  
  # Ensure the correct version of Swift is used
  s.pod_target_xcconfig = { 'SWIFT_VERSION' => '2.3' }  
  
  s.subspec 'Core' do |ss|
    ss.source_files = [
      'Sources/YapDatabaseExtensions.swift',
      'Sources/YapDB.swift'      
    ]
  end
  
  s.subspec 'Functional' do |ss|
    ss.dependency 'YapDatabaseExtensions/Core'
    ss.source_files = 'Sources/Functional_*.swift'
  end

  s.subspec 'Persitable' do |ss|
    ss.dependency 'YapDatabaseExtensions/Functional'
    ss.source_files = [
      'Sources/Read.swift', 
      'Sources/Persistable_*.swift'
    ]
  end
end

