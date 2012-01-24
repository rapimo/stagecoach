require 'yaml'
require 'FileUtils'

module Stagecoach
  class Config
    class << self
      def new
        case STDIN.gets.chomp
        when 'C'
          File.open(CONFIG_FILE, 'w') { |f| f.write("---\nredmine_site: none\nredmine_api_key: none")}
        when 'Q'
          puts "Exiting..."
          exit
        end
      end

      def open
        File.open(CONFIG_FILE, 'r+')
      end

      def yaml_to_hash 
        YAML::load(Config.open)
      end

      def save(hash, config_file = Config.open)
        config_file.write(hash.to_yaml)
      end

      def githook_install(source_dir, install_dir, file)
        FileUtils.cp(source_dir + file, install_dir + file)
        puts 'OK!'
        puts 'Making githook executable (may require admin password)'
        FileUtils.chmod(0711, ( install_dir + file ))
        puts 'OK!'
      end

      def setup
        # Say hello
        CommandLine.line_break
        puts "Stagecoach Initial Setup"
        CommandLine.line_break

        # Now scare everybody away again
        puts "You are running stagecoach from #{FileUtils.pwd.green}. Is this the root directory of your repository?" 
        puts "Stagecoach may not work properly anywhere else! So proceed with caution"
        CommandLine.line_break
        print "[C]ontinue or [Q]uit:"

        # Create a config file if necessary (Config.new deals with the C or Q input for now although it is ugly)
        Config.new

        # Tell git to ignore the stagecoach config file
        Git.global_ignore('.stagecoach')

        # Install the commit-msg githook if it is not already there:
        source_dir = (File.dirname(__FILE__) + '/../githooks/')
        install_dir = FileUtils.pwd + '/.git/hooks/'
        git_hook = 'commit-msg'  

        CommandLine.line_break
        puts "Would you like to install the stagecoach #{"commit-msg githook".green}?"
        puts "This automatically references stagecoach-created github issues from each commit you make"
        puts "Note that this will only affect branches created in stagecoach.  For more information run stagecoach -h"
        CommandLine.line_break
        puts "[I]nstall or [S]kip this step"
        loop do
          case STDIN.gets.chomp
          when 'I'
            if File.exist?(install_dir + git_hook)
              case FileUtils.compare_file(source_dir + git_hook, install_dir + git_hook) 
              when true
                puts 'The stagecoach githook is already installed in this repo. Skipping this step...'
                break
              when false
                puts "You have a commit-msg githook already.  Are you sure you want to install?  This will #{'overwrite'.red} your current commit-msg githook."
                print "Type [overwrite] to continue or anything else to skip installation:"
                case STDIN.gets.chomp
                when 'overwrite'
                  Config.githook_install(source_dir, install_dir, git_hook)
                  break
                else
                  break
                end
              end
            else
              puts "Installing..."
              Config.githook_install(source_dir, install_dir, git_hook)
              break
            end
          when 'S'
            puts 'Skipping Installation.'
            break
          end
        end

        # TODO Some verification of the input at this stage, for example test the
        # connection and have the user re-enter the details if necessary 
        # http://api.rubyonrails.org/classes/ActiveResource/Connection.html#method-i-head
        loop do 
          CommandLine.line_break
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
