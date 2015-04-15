namespace :xcode do

	def exportXcodeVersion
		command = "xcodebuild -version"
		sh command
	end
	
	def killSimulator
		command = "killall QUIT iOS\ Simulator"
		result = system(command)
	end
	
	def message(text)
		puts "--- #{text}"
	end

	def updateSubmodules
		message("Updating Submodules")
		command = "git submodule update --init"
		result = system(command)
	end

	def provideDefaultEnvironmentVariables
		ENV['PROJECT_DIR'] = 'YapDBExtensionsMobile' unless ENV.has_key?('PROJECT_DIR')
		ENV['OUTPUT_DIR'] = 'output' unless ENV.has_key?('OUTPUT_DIR')		
		ENV['ARTIFACT_DIR'] = 'artifacts' unless ENV.has_key?('ARTIFACT_DIR')
		
		ENV['WORKSPACE'] = 'YapDBExtensionsMobile' unless ENV.has_key?('WORKSPACE')
		ENV['SDK'] = 'iphonesimulator' unless ENV.has_key?('SDK')
		ENV['CONFIGURATION'] = 'Debug' unless ENV.has_key?('CONFIGURATION')
	end

	def projectDirectory
		return "#{Dir.pwd}/#{ENV['PROJECT_DIR']}"
	end

	def podsRoot
		return "#{projectDirectory()}/Pods"
	end

	def workspaceArgument
		return "-workspace \"#{ENV['PROJECT_DIR']}/#{ENV['WORKSPACE']}.xcworkspace\""
	end

	def configurationArgument
		return "-configuration #{ENV['CONFIGURATION']}"
	end

	def derivedDataPathArgument
		return "-derivedDataPath #{ENV['OUTPUT_DIR']}"
	end

	def buildProductsDirectory
		return "#{Dir.pwd}/#{ENV['OUTPUT_DIR']}/Build/Products/#{ENV['CONFIGURATION']}-iphoneos"	
	end

  def archivePath(scheme)
		return "#{Dir.pwd}/#{ENV['ARTIFACT_DIR']}/#{scheme}.xcarchive"    
  end

  def archivePathArgument(scheme)
    path = archivePath(scheme)
		return "-archivePath #{path}"
  end

	def packageApplicationArgument(scheme)
		return "#{buildProductsDirectory()}/#{scheme}.app"	
	end

	def packageOutputArgument
		return "#{Dir.pwd}/#{ENV['ARTIFACT_DIR']}"
	end

	def codeSigningArgument
		return "OTHER_CODE_SIGN_FLAGS=\"--keychain #{ENV['KEYCHAIN']}\""
	end

	def checkPods
		manifest = "#{podsRoot()}/Manifest.lock"
		if File.file? manifest
			message("Updating Cocoapods")
			sh "pod --no-repo-update update"
		else
			message("Installing Cocoapods")		
			sh "pod --no-repo-update install"
		end
	end

	def prepareForBuild
		command = "mkdir -p #{ENV['OUTPUT_DIR']}"
		sh command
	end

	def prepareForArtifacts
		command = "mkdir -p #{ENV['ARTIFACT_DIR']}"
		sh command
	end

	def test(scheme)
		message("Testing #{scheme}")	    
#		command = "xcodebuild #{workspaceArgument()} #{configurationArgument()} -sdk #{ENV['SDK']} -scheme #{scheme} test | xcpretty -c && exit ${PIPESTATUS[0]}"
    command = "xctool #{workspaceArgument()} #{configurationArgument()} -sdk #{ENV['SDK']} -scheme #{scheme} -reporter pretty test && exit ${PIPESTATUS[0]}"
		sh command
	end

	def build(scheme, app)
		message("Building #{scheme}")	
		prepareForBuild()
		command = "xcodebuild #{workspaceArgument()} #{configurationArgument()} -sdk iphoneos -scheme #{scheme} #{derivedDataPathArgument()} clean build | xcpretty -c && exit ${PIPESTATUS[0]}"
		sh command
	end

	def package(scheme, ipa)
		message("Packaging #{scheme}")	
		prepareForArtifacts()
		command = "xcrun -sdk iphoneos PackageApplication -v \"#{packageApplicationArgument(scheme)}\" -o \"#{packageOutputArgument()}/#{ipa}\""
		sh command
	end
  
  def archive(scheme)
    message("Archiving #{scheme}")
    command = "xcodebuild #{workspaceArgument()} #{configurationArgument()} -sdk iphoneos -scheme #{scheme} #{archivePathArgument(scheme)} clean archive | xcpretty -c && exit ${PIPESTATUS[0]}"
		sh command    
  end
  
  def zip_archive(scheme)
    message("Zipping #{scheme} archive")
    command = "zip -r #{archivePath(scheme)}.zip #{archivePath(scheme)}"
    sh command
  end
  
  def distribute_hockey(scheme)
		message("Distributing #{scheme} To HockeyApp")
    command = "/usr/local/bin/puck -submit=auto -download=true -notify=false -upload=all -mandatory=false -build_server_url=#{ENV['BUILDKITE_BUILD_URL']} -commit_sha=#{ENV['BUILDKITE_COMMIT']} -repository_url=git@github.com/yakatak/ios.git -app_id=#{ENV['HOCKEYAPP_ID']} -api_token=#{ENV['HOCKEYAPP_TOKEN']} #{archivePathArgument(scheme)}"
		sh command
  end
	
	desc 'Configure Environment'
	task :configure_env do
		exportXcodeVersion()
		provideDefaultEnvironmentVariables()		
	end

	desc 'Update Submodules'
	task :update_submodules do
		updateSubmodules()
	end

	desc 'Update Cocoapods'
	task :pods => ['configure_env', 'update_submodules'] do
		Dir.chdir(projectDirectory()) do			
			checkPods()
		end
	end

	namespace :test do

		desc 'Runs Unit on iOS'
    task :mobile => ['pods'] do
			killSimulator
			test('YapDBExtensionsMobile')      
    end

		desc 'Runs Unit Tests'
		task :go  => ['mobile'] do
		end

	end

	namespace :build do
	end
	
  namespace :archive do
  end

  namespace :distribute do
  end

	namespace :package do
	end		
end
