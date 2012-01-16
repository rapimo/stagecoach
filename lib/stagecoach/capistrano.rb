module Stagecoach
  class Capistrano
    def deploy(branch)
      CommandLine.line_break
      puts "Deploying staging"
      puts `bundle exec cap #{branch} deploy`
    end
  end
end
