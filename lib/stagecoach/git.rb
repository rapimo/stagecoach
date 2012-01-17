module Stagecoach
  class Git
    class << self
      def branches
        `git branch`.split("\n")
      end

      def changes
        `git diff-files --name-status -r --ignore-submodules`
      end

      def current_local_branch
        branches.each do |b| 
          if b =~ /\*/
            return b[1..-1].strip
          end
        end
      end

      def correct_branch?
        branch = Git.current_local_branch
        puts "You are currently in local branch: #{branch.red} \nAre all these details correct? ([Y]es or [Q]uit):"
        case STDIN.gets.chomp
        when "Y"
        when "Q"
          exit
        else
          puts "Please enter Y to continue or Q to quit."
        end
      end
      def new_branch(branch)
        `git checkout -b #{branch}`
      end

      def change_to_branch(branch)
        puts "Changing to branch '#{branch}'"
        if branch_exist?(branch)
          `git checkout #{branch}`
        else
          puts "Branch '#{branch}' does not exist. [C]reate or [Q]uit"
          case STDIN.gets.chomp
          when 'C'
            new_branch(branch)
          when 'Q'     
            exit
          end
        end
      end

      def diff_from_master(branch)
        diff = `git diff master #{branch}`
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

      def unpushed_commits?
        if `git log --branches --not --remotes`.length > 1
          return "1"
        else
          return "0"
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
