require 'yaml'

module Stagecoach
  class Config

    @config_file_location = (File.dirname(__FILE__) + '/config.yaml')

    def self.open
      File.open(@config_file_location, 'r+')
    end

    def self.yaml_to_hash 
      YAML::load(self.open)
    end

    def self.save(hash, config_file = self.open)
      config_file.write(hash.to_yaml)
    end

    def self.setup
      CommandLine.line_break
      puts "Stagecoach Initial Setup"
      CommandLine.line_break
      loop do 
        puts "Enter your redmine/planio repository, eg. http://digitaleseiten.plan.io:"
        redmine_repo = STDIN.gets.chomp
        puts "Enter your API key for that repo:"
        redmine_api_key = STDIN.gets.chomp

        config_hash = {"redmine_site" => redmine_repo, "redmine_api_key"  => redmine_api_key}

        self.save(config_hash)

        puts "Settings saved OK:"
        puts "Repository:" + redmine_repo
        puts "API Key:   " + redmine_api_key
        puts "Continue? [Y]es or [N]o"
        break if STDIN.gets.chomp == 'Y'
        redo if STDIN.gets.chomp == 'N'
      end 
    end
  end
end

class String
  def red; colorize(self, "\e[1m\e[31m"); end
  def green; colorize(self, "\e[32m"); end
  def colorize(text, color_code)  "#{color_code}#{text}\e[0m" end
end
