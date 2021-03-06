module Stagecoach
  class Git
    class << self
      def branches
        `git branch`.split("\n")
      end

      def global_ignore_file(set = nil)
         `git config --global core.excludesfile #{set}`
      end

      def global_ignore(filename)
        # Check if filename is ignored already and ignores it if not
        gitignore = Git.global_ignore_file.strip 
          unless File.read(gitignore) =~ /\.stagecoach/
            gitignore.puts(filename)
          end
      end
      
      def global_config(header, config)
        `git config --global #{header}.#{config}`
      end

      def set_global_config(header, config, value)
        `git config --global #{header}.#{config} #{value}`
      end

      def changes
        `git diff-files --name-status -r --ignore-submodules`
      end
      
      def status
        `git status`
      end

      def current_branch
        branches.each do |b| 
          if b =~ /\*/
            return b[1..-1].strip
          end
        end
      end

      def correct_branch?
        CommandLine.line_break
        print "You are currently in local branch: #{Git.current_branch.red} \nAre these details correct? ([Y]es or [Q]uit):  "
        case STDIN.gets.chomp
        when "Y"
        when "Q"
          exit
        else
          puts "Please enter Y to continue or Q to quit."
        end
      end

      def new_branch(branch)
        CommandLine.line_break
        `git checkout -b #{branch}`
      end

      def change_to_branch(branch)
        CommandLine.line_break
        puts "Changing to branch '#{branch}'"
        if branch_exist?(branch)
          `git checkout #{branch}`
        else
          print "Branch '#{branch}' does not exist. [C]reate or [Q]uit:  "
          case STDIN.gets.chomp
          when 'C'
            new_branch(branch)
          when 'Q'     
            exit
          end
        end
      end

      def diff(branch1, branch2)
        diff = `git diff --name-status #{branch1}..#{branch2}`
        return diff
      end


      def merge(to_branch, from_branch)
        CommandLine.line_break
        puts "Merging into #{to_branch} (after pulling updates)"
        Git.change_to_branch(to_branch)
        puts `git pull origin #{to_branch}`
        puts `git merge #{from_branch}`
        raise 'merge failed' if $?.exitstatus != 0
      end

      def push(branch)
        CommandLine.line_break
        puts "Pushing your changes to branch '#{branch}'"
        puts `git push origin #{branch}`
      end


      def checkout(branch) 
        puts `git checkout #{branch}`
      end

      def pull
        puts `git pull`
      end

      def branch_exist?(branch)
        branches.find { |e| /#{branch}/ =~ e }
      end

      def new_issue(title, description)
        `ghi -o "#{title}" -m "#{description}"`
      end

      def branch_has_commits?(branch)
        log = `git log --branches --not --remotes --simplify-by-decoration --decorate --oneline`
        if log.include? branch
          return true
        else
          return false
        end
      end

      def view_issue(github_issue)
        `ghi -u#{github_issue}`
      end

      def issue(id)
        `ghi -l #{id}`
      end
    end
  end
end
