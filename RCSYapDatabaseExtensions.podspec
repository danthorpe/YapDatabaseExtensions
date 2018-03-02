Pod::Spec.new do |s|
  s.name              = "RCSYapDatabaseExtensions"
  s.version           = "4.0.2"
  s.summary           = "Helpers for using value types with YapDatabase."
  s.description       = <<-DESC

  Defines APIs to conveniently read, write and remove objects and values
  to or from YapDatabse. See ValueCoding for value type support.

                       DESC
  s.homepage          = "https://github.com/JimRoepcke/YapDatabaseExtensions"
  s.license           = 'MIT'
  s.authors           = { "Daniel Thorpe" => "@danthorpe", "Jim Roepcke" => "@JimRoepcke" }
  s.source            = { :git => "https://github.com/JimRoepcke/YapDatabaseExtensions.git", :tag => s.version.to_s }
  s.module_name       = 'RCSYapDatabaseExtensions'
  s.social_media_url  = 'https://twitter.com/JimRoepcke'
  s.requires_arc      = true
  s.swift_version     = '4.0'
  s.default_subspec   = 'Persitable'
  s.ios.deployment_target = '9.0'
  s.osx.deployment_target = '10.11'

  s.dependency 'CocoaLumberjack', '~> 3.4.1'
  s.dependency 'ValueCoding', '~> 2.2.0'
  s.dependency 'YapDatabase', '~> 3.0.2'

  s.subspec 'Core' do |ss|
    ss.source_files = [
      'Sources/YapDatabaseExtensions.swift',
      'Sources/YapDB.swift'
    ]
  end

  s.subspec 'Functional' do |ss|
    ss.dependency 'RCSYapDatabaseExtensions/Core'
    ss.source_files = 'Sources/Functional_*.swift'
  end

  s.subspec 'Persitable' do |ss|
    ss.dependency 'RCSYapDatabaseExtensions/Functional'
    ss.source_files = [
      'Sources/Read.swift',
      'Sources/Persistable_*.swift'
    ]
  end
end
