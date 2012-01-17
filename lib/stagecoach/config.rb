require 'yaml'

module Stagecoach
  class Config
    class << self
      def open
        File.open((File.dirname(__FILE__) + '/config.yaml'), 'r+')
      end

      def yaml_to_hash 
        YAML::load(Config.open)
      end

      def save(hash, config_file = Config.open)
        config_file.write(hash.to_yaml)
      end

      def setup
        CommandLine.line_break
        puts "Stagecoach Initial Setup"
        CommandLine.line_break
        loop do 
          puts "Enter your redmine/planio repository, eg. https://digitaleseiten.plan.io:"
          redmine_repo = STDIN.gets.chomp
          puts "Enter your API key for that repo:"
          redmine_api_key = STDIN.gets.chomp

          config_hash = {"redmine_site" => redmine_repo, "redmine_api_key"  => redmine_api_key}

          Config.save(config_hash)

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
