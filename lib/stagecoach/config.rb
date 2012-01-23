require 'yaml'

module Stagecoach
  class Config
    class << self
      def new
        print <<WARNING
You are running stagecoach from #{`pwd`.chomp}. Is this correct? 
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

        # TODO Some verification of the input at this stage, for example test the
        # connection and have the user re-enter the details if necessary 
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
