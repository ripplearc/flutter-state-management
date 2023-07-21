import './helper/BuildAction.rb'

default_platform(:ios)

RUNNING_ON_CI = ENV['CI'].to_s.downcase == 'true'
APPLE_ID = ENV['TOD_APPLE_ID'].to_s
BUNDLE_IDENTIFIER = 'com.ripplearc.composerandomwords'

platform :ios do
  lane :setup_keychain do
    create_keychain(
      name: 'itcKeychain',
      default_keychain: false,
      password: 'secretPass',
      unlock: true,
      timeout: 3600,
      lock_when_sleeps: true
    )
  end

  desc "Lane to add a new device to provisioning profiles
        If you want to add a new device run:

        ```
        fastlane add_device
        ```

        After the new device was added you can refresh your provisioning profile by running:
        ```
        fastlane renew_profile
        ```
  "

  lane :add_device do
    device_name = prompt(text: 'Enter the device name: ')
    device_udid = prompt(text: 'Enter the device UDID: ')
    device_hash = {}
    device_hash[device_name] = device_udid
    register_devices(
      devices: device_hash
    )
  end

  lane :refresh_appstore_profiles do
    match(app_identifier: BUNDLE_IDENTIFIER, type: 'appstore', readonly: false, force: true,
          force_for_new_devices: true, keychain_password: 'secretPass')
  end

  lane :refresh_development_profiles do
    match(app_identifier: BUNDLE_IDENTIFIER, type: 'development', readonly: false, force: true,
          force_for_new_devices: true, keychain_password: 'secretPass')
  end

  lane :refresh_all_profiles do
    refresh_development_profiles
    refresh_appstore_profiles
  end

  private_lane :remove_old_profiles do
    sh('fastlane sigh manage -p "' + BUNDLE_IDENTIFIER + '" --force')
  end

  desc 'Test'
  lane :test do
    common_build_actions
  end

  desc 'Builds an appstore version of the application and distributes to AppStore Connect'
  lane :deploy do
    common_build_actions
    Dir.chdir '..' do
      sh('flutter', 'build', 'ios', '--release', '--no-codesign')
    end

    match(app_identifier: BUNDLE_IDENTIFIER, type: 'appstore', keychain_password: 'secretPass',
          readonly: RUNNING_ON_CI)

    build_app(
      scheme: 'Runner',
      workspace: 'ios/Runner.xcworkspace',
      configuration: 'Release',
      export_method: 'app-store'
    )

    pilot(
      username: APPLE_ID,
      team_id: '120815547',
      skip_submission: false,
      skip_waiting_for_build_processing: true,
      apple_id: '6449834100'
    )
  end
end

platform :android do
  desc 'Builds and signs a production release to distribute in Google Play Store'
  lane :deploy do |options|
    build_number = options[:build_number] || ENV['BUILD_NUMBER'].to_s
    common_build_actions
    Dir.chdir '..' do
      sh("flutter build appbundle --build-number=#{build_number}")
    end

    supply(
      aab: 'build/app/outputs/bundle/release/app-release.aab',
      mapping: 'build/app/outputs/mapping/release/mapping.txt',
      json_key: 'google_play.json',
      release_status: 'completed',
      track: 'internal',
      skip_upload_metadata: true,
      skip_upload_images: true,
      skip_upload_screenshots: true,
      package_name: BUNDLE_IDENTIFIER
    )
  end
end
