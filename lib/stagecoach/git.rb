module Stagecoach
  class Git
    def self.branches
      `git branch`.split("\n")
    end

    def self.changes
      `git diff-files --name-status -r --ignore-submodules`
    end

    def self.current_local_branch
      self.branches.each do |b| 
        if b =~ /\*/
          return b[1..-1].strip
        end
      end
    end

    def self.new_branch(branch)
      `git checkout -b #{branch}`
    end

    def self.change_to_branch(branch)
      `git checkout #{branch}`
    end

    def self.new_issue(title, description)
      `ghi -o "#{title}" -m "#{description}"`
    end

    def self.unpushed_commits?
      if `git log origin/master..HEAD`.length > 1
        return "1"
      else
        return "0"
      end
    end

    def self.view_issue(github_issue)
      `ghi -u#{github_issue}`
    end
  end
end
