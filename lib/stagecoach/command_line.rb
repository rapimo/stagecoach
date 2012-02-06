module Stagecoach
  class CommandLine
    def self.line_break
      puts  "\n"
    end

    def self.trollop
      require 'trollop'
      # Command line options using Trollop.
      Trollop::options do
        banner <<-EOS
stagecoach works in two stages, init and deploy. The init stage creates a branch based on a redmine/planio issue, and the deploy stage pushes, merges and (yes!) deploys it. 

#{"You should always run stagecoach from the root directory of your repo".red}
Otherwise it may (will) break.

The first time you run stagecoach it will ask you for some information, namely your redmine/planio repo URL and your API key for this repo.
It will also install a custom commit-msg git hook (if you ask it to) - for more information, see below.  

All stagecoach config is saved in /path/to/your/repo/.stagecoach which is created at initial setup and added to your global .gitignore.  This is a yaml file with fairly obvious syntax
so if you need to remove a branch or edit the issue number that a branch points to, it is possible (although not necessarily recommended) to edit it.

Init Stage
----------
stagecoach -p[lanio] 4115 (OR) -g[ithub] 525 -b[ranch] my_new_branch

You can also just run stagecoach without any flags and it will allow you to enter this stuff manually.

To get started, all stagecoach needs from you is the issue number you are working on (redmine/planio or github) and a new branch name.  You /can/ use an existing branch if it 
is up to date with your master branch. If it is not, stagecoach will squawk and die and you will have to bring the branch up to date, or use a new one.
  
If you are working from a redmine/planio issue, stagecoach sets the issue to 'In Progress'.  Currently it does not assign the issue to you, but you have the option to view the issue
in your browser and do this manually.  It also sets up a git issue for you to reference in your commits (see commit-msg githook).

If you are working from a github issue, we can all get on with our lives.

Coding Stage
------------
Future versions of stagecoach may do the coding for you, but at the moment you have to do this part manually.
Just code and commit, code and commit until your feature or fix is ready.

#{"commit-msg githook".green}
If you opt to install the commit-msg githook during initial setup (stagecoach -s) then your commit messages will be automatically referenced to the github issue of the branch you are in 
(this only applies to branches created or registered in Stagecoach).

  - to reference a different issue from a commit, simply refer to it as normal with #xxx in the commit message. The git-hook will leave your message alone.
  - to make no reference at all, you can use the #noref tag in the commit message. The git-hook
  - to close an issue with a commit, use the #closes tag.

For more information, see 
  - the githook itself at /path/to/your/repo/.git/hooks/commit-msg
  - http://book.git-scm.com/5_git_hooks.html

Deploy Stage
------------
stagecoach -d[eploy]

This automates the entire deploy workflow for you as follows:

  git push origin new_branch_name
  git checkout staging
  git pull
  git merge task_name
  git push origin staging
  cap staging deploy
  set redmine/planio ticket to 'feedback' status (if applicable)
 
#{"Sample usage:".green}
  stagecoach -p 4115 -b new_branch_name
  [code, commit until feature or fix is complete]
  stagecoach -d

#{"Flags".red}
        EOS
        opt :branch, "Enter your new branch name here, eg. stagecoach -b new_branch (optional)", :type => :string
        opt :redmine, "Enter your redmine/planio issue number here, eg. stagecoach -r 1234 (optional)", :type  => :string
        opt :github, "Enter your github issue number here, eg. stagecoach -g 1234 (optional)", :type => :string
        opt :push, "Use this option to push your changes to your remote branch (will be created if necessary)"
        opt :deploy, "Use this option to  deploy from your current branch to any branch you choose, eg. stagecoach -d staging", :type => :string 
        opt :setup, "Use this the first time you run stagecoach to save your redmine repository and api key"
      end
    end
  end
end
