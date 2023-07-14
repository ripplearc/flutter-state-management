def print_table(data)
  max_length = data.max_by(&:length).length

  puts 'Modified Files: 📝 '
  puts '-' * max_length

  data.each do |item|
    puts item
  end

  puts '-' * max_length
end

# Test coverage explains with lcov on Flutter
# https://www.etiennetheodore.com/test-coverage-explain-with-lcov-on-dart/
def check_overall_code_coverage(code_coverage_target, lcov_info_path)
  Dir.chdir('..') do
    code_coverage = sh("lcov --summary #{lcov_info_path} | grep 'lines......' | cut -d ' ' -f 4 | cut -d '%' -f 1", log: false).strip.to_f

    if code_coverage < code_coverage_target.to_f
        message = "Overall code coverage #{code_coverage}%" +
                    " is less than expected #{code_coverage_target}%"
        UI.important(message)
        UI.user_error!('Code coverage threshold not met ❌ ')
    else
        UI.message("Overall Code Coverage: #{code_coverage}% ✅ ")
    end
  end
end

def check_incremental_code_coverage(incremental_code_coverage_target, lcov_info_path)
  Dir.chdir('..') do
    sh("git fetch origin main:benchmark")
    current_branch = sh("git rev-parse --abbrev-ref HEAD", log: false).strip
    modified_files = sh("git diff --name-only benchmark -- 'lib/*'", log: false).strip.split("\n")
    if modified_files.empty?
      UI.important('No modified files found in the lib directory. ✅ ')
      next
    end
    print_table(modified_files)

    modified_files_argument = modified_files.join(' ')
    sh("lcov --extract coverage/lcov.info #{modified_files_argument} --output-file coverage/incremental_lcov.info")

    incremental_code_coverage = sh("lcov --summary coverage/incremental_lcov.info | grep 'lines......' | cut -d ' ' -f 4 | cut -d '%' -f 1", log: false).strip.to_f
    if incremental_code_coverage < incremental_code_coverage_target.to_f
       UI.important("Incremental code coverage #{incremental_code_coverage}%" +
        " is less than expected #{incremental_code_coverage_target}%")
       UI.user_error!("Incremental code coverage threshold not met ❌ ")
    else
        UI.message("Incremental Test Coverage for Modified Files in the lib Directory: #{incremental_code_coverage}% ✅ ")
    end
  end
end

def upload_coverage_to_codecov(codecov_token)
  sh("curl -Os https://uploader.codecov.io/latest/macos/codecov")
  sh("chmod +x codecov")
  sh("./codecov -t #{codecov_token}")
end
