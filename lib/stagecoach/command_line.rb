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
Stagecoach works in two stages.  When supplied with an issue number (redmine/planio or github) and a new branch name it essentially runs:

  checkout master
  git pull
  git checkout -b <new_branch_name>
  
If you are working from a redmine/planio issue, it assigns that issue to you and sets it to 'In Progress'.
It also sets up a git issue for you to reference in your commits.

If you are working from a github issue, it assigns that issue to you.

Then you can code and commit, code and commit until your feature or fix is ready.

Once this is done you can run stagecoach -d[eploy]

This automates the entire deploy workflow for you as follows:

  git push origin new_branch_name
  git checkout staging
  git pull
  git merge task_name
  set redmine/planio ticket to 'feedback' status if applicable
  submits a pull request on Github
 
#{"Sample usage:".green}
  stagecoach -p 4115 -b new_branch_name
  [code, commit until feature or fix is complete]
  stagecoach -d

#{"Flags".red}
        EOS
        opt :branch, "Enter your new branch name here, eg. stagecoach -b new_branch (optional)", :type => :string
        opt :planio, "Enter your planio issue number here, eg. stagecoach -p 1234 (optional)", :type  => :string
        opt :github, "Enter your github issue number here, eg. stagecoach -g 1234 (optional)", :type => :string
        opt :deploy, "Use this option to skip straight to push & deploy if you have already pulled from master and created your new branch"
        opt :setup, "Use this the first time you run stagecoach to save your redmine repository and api key"
        opt :testing, "Dev testing tool"
      end
    end
  end
end
