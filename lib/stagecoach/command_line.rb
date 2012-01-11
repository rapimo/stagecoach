module Stagecoach
  class CommandLine
    def self.line_break
      puts  ("-" * 50)
    end

    def self.trollop
      require 'trollop'
      # Command line options using Trollop.
      Trollop::options do
        banner <<-EOS

#{"Sample usage:".green}
  stagecoach -i[ssue] 4115 -b[ranch] new_branch_name
  [code, commit] * n
  stagecoach -d[eploy]

Stagecoach works in two stages.  When supplied with a planio issue number and a new branch name it does:

  checkout master
  git pull
  git checkout -b <new_branch_name>

Then you can code and commit, code and commit until your feature or fix is ready.

Once this is done you can run stagecoach -d[eploy]

This automates the entire workflow for you as follows:

  git push origin new_branch_name
  git checkout staging
  git pull
  git merge task_name
  [attempts to set planio ticket to 'feedback' status - currently this is not supported by the redmine API and must be done manually]
 
#{"Flags".red}
        EOS
        opt :deploy, "Use this option to skip straight to push & deploy if you have already pulled from master and created your new branch"
        opt :branch, "Enter your new branch name here", :type => :string
        opt :issue, "Enter your planio issue number here,  e.g. stagecoach -i 4115", :type  => :string
      end
    end
  end
end
