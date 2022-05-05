platform :ios, '14.0'

target 'CloudCards' do

  use_frameworks!

  pod 'RealmSwift', '10.25.2'
  pod 'Firebase/Storage', '9.0.0'
  pod 'Firebase/Firestore', '9.0.0'
  pod 'FirebaseFirestoreSwift', '9.0.0'
  pod 'Kingfisher', '7.2.1'
  pod 'TableKit'
  pod 'SnapKit'
  pod 'PanModal'
  pod 'SwiftLint'
end

min_supported_deployment_target = Version.new(14.0)

post_install do |pi|
  pi.pods_project.targets.each do |target|
     target.build_configurations.each do |config|
      build_config_version = Version.new(config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'])
      max_deployment_target = [build_config_version, min_supported_deployment_target].max

      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = max_deployment_target.to_s
    end
  end
end