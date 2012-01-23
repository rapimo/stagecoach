require 'yaml'

module Stagecoach
  class Config
    class << self
      def new
        print <<WARNING
You are running stagecoach from #{FileUtils.pwd}. Is this correct? 
#{"Note:".red} stagecoach branch information will be saved here (and .gitignored) [C]ontinue or [Q]uit:
WARNING
        case STDIN.gets.chomp
        when 'C'
          File.open(CONFIG_FILE, 'w') { |f| f.write("---\nredmine_site: none\nredmine_api_key: none")}
        when 'Q'
          puts "Exiting..."
          exit
        end
      end

      def open
        File.open(CONFIG_FILE, 'a+')
      end

      def yaml_to_hash 
        YAML::load(Config.open)
      end

      def save(hash, config_file = Config.open)
        config_file.write(hash.to_yaml)
      end

      def setup
        # Say hello
        CommandLine.line_break
        puts "Stagecoach Initial Setup"
        CommandLine.line_break

        # Ignore the stagecoach config file
        Git.global_ignore('.stagecoach')

        # Create a config file if necessary
        Config.new

        # Install the commit-msg githook if we want to
        puts "Would you like to install the stagecoach git-hook to automatically reference github issues from each commit?"
        puts "Note that this will not affect branches not created in stagecoach.  For more information run  stagecoach -h"
        puts "[I]nstall or [S]kip this step"
        case STDIN.gets.chomp

        when 'I'
          source_file = (File.dirname(__FILE__) + '/../githooks/commit-msg')
          install_dir = FileUtils.pwd + '/.git/hooks'
          
          p 'Installing...'
          FileUtils.cp(source_file, install_dir)
          p 'Making githook executable (with chmod):'
          FileUtils.chmod "u+x", ( install_dir + '/commit-msg' )

        when 'S'
        end

        # TODO Some verification of the input at this stage, for example test the
        # connection and have the user re-enter the details if necessary 
        # http://api.rubyonrails.org/classes/ActiveResource/Connection.html#method-i-head
        loop do 
          print "Enter your redmine/planio repository, eg. https://digitaleseiten.plan.io:  "
          redmine_repo = STDIN.gets.chomp
          print "Enter your API key for that repo:  "
          redmine_api_key = STDIN.gets.chomp

          Config.save({"redmine_site" => redmine_repo, "redmine_api_key"  => redmine_api_key})

          CommandLine.line_break
          puts "Settings saved OK:"
          puts "Repository: " + redmine_repo
          puts "API Key:    " + redmine_api_key
          CommandLine.line_break
          puts "Exiting..."
          exit
        end 
      end 
    end
  end
end

class String
  def red; colorize(self, "\e[1m\e[31m"); end
  def green; colorize(self, "\e[32m"); end
  def colorize(text, color_code)  "#{color_code}#{text}\e[0m" end
end
