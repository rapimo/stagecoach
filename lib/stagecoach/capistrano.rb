module Stagecoach
  class Capistrano
    class << self
      def deploy(branch)
        CommandLine.line_break
        puts "Deploying staging"
        puts `bundle exec cap #{branch} deploy`
      end
    end
  end
end
