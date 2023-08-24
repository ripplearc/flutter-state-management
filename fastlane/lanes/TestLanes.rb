import 'helper/BuildAction.rb'
import 'helper/CodeCoverage.rb'

def close_driver_port(port)
  command = <<~BASH
    if nc -z localhost #{port}; then
       sudo kill -9 $(lsof -t -i :#{port})
    fi
  BASH

  sh(command, print_command: false)
end

lane :run_unit_widget_golden_tests do |options|
  test_report_path = options[:test_report_path]
  common_build_actions
  Dir.chdir('..') do
    sh('HOMEBREW_NO_AUTO_UPDATE=1 brew install lcov')
    sh("flutter test --coverage --machine > #{test_report_path}")
  end

  code_coverage_target = options[:code_coverage_target]
  incremental_code_coverage_target = options[:incremental_code_coverage_target]
  lcov_info_path = options[:lcov_info_path]

  check_overall_code_coverage(code_coverage_target, lcov_info_path)
  check_incremental_code_coverage(incremental_code_coverage_target, lcov_info_path)
  upload_coverage_to_codecov(options[:codecov_token])
end

lane :run_ios_integration_tests do |options|
  test_report_path = options[:test_report_path]
  # Execute ios integration tests
  common_build_actions
  Dir.chdir '..' do
    sh("xcrun simctl shutdown all \
        && TEST_DEVICE=$(xcrun simctl create test-device com.apple.CoreSimulator.SimDeviceType.iPhone-11 com.apple.CoreSimulator.SimRuntime.iOS-16-4) \
        && xcrun simctl boot $TEST_DEVICE \
        && flutter -d $TEST_DEVICE test integration_test \
        --machine > #{test_report_path}")
  end
end

lane :run_web_chrome_integration_tests do |options|
  port_number = options[:port]
  # Execute Chrome integration tests
  common_build_actions
  close_driver_port(port_number)
  Dir.chdir '..' do
    sh("brew upgrade --cask chromedriver \
        && chromedriver --version")
    Process.spawn("chromedriver --port=#{port_number} &")
    sh("flutter config --enable-web \
        && flutter drive \
           --driver=test_driver/integration_driver.dart \
           --target=integration_test/app_test.dart \
           -d web-server --driver-port=#{port_number} --release --browser-name chrome")
  end
end

lane :run_web_safari_integration_tests do |options|
  port_number = options[:port]
  # Execute Chrome integration tests
  common_build_actions
  close_driver_port(port_number)
  Dir.chdir '..' do
    sh('sudo safaridriver --enable')
    Process.spawn("safaridriver --port #{port_number} &")
    sh("flutter config --enable-web \
        && flutter drive \
           --driver=test_driver/integration_driver.dart \
           --target=integration_test/app_test.dart \
           -d web-server --driver-port=#{port_number} --release --browser-name safari")
  end
end
