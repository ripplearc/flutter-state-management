RUNNING_ON_CI = ENV['CI'].to_s.downcase == 'true'

def common_build_actions()
  Dir.chdir ".." do
    if (RUNNING_ON_CI == false) then
      sh("flutter", "clean")
    end
    sh("flutter", "pub", "get")
    sh('flutter pub run build_runner build')
    sh("flutter", "analyze")
  end
end

