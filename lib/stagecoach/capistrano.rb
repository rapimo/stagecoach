module Stagecoach
  class Capistrano
    def deploy(branch)
    puts `bundle exec cap #{branch} deploy`
    end
  end
end
