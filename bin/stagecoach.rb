#! usr/bin/env ruby
# encoding: utf-8
require '../lib/stagecoach.rb'

module Stagecoach
  # Command line options courtesy of the Trollop gem.
  # lib/stagecoach/command_line.rb 
  opts = CommandLine.trollop

  # Set up configuration variables.
  config = Config.yaml_to_hash
  config_file = Config.open

  # Set up redmine_client config.
  RedmineClient::Base.configure do
    self.site = config["redmine_site"]
    self.user = config["redmine_api_key"]
  end

  # Checks that command-line args are present and correct.
  Trollop::die :issue, "number can only contain digits" if opts[:issue] && opts[:issue][/\D/]
  Trollop::die :branch, "name must be longer than 1 character" if opts[:branch] && opts[:branch].length <= 1
  Trollop::die :deploy, "needs some commits! Do some coding before running deploy" if opts [:deploy] && Git.status == "no_commits"

  # Saves the issue number for later.
  if opts[:issue]
    config["issue_number"] = opts[:issue] 
    Config.save(config, config_file)
  end

  unless opts[:deploy]
    # Checks for uncommitted/unstashed changes and aborts if present.
    if Git.changes.size > 1
      puts "You have uncommitted changes:".red
      puts Git.changes
      puts "Please commit or stash these changes before running Stagecoach. -h for help."
      exit
    end 

    # Change to master, pull changes, and create a new branch
    CommandLine.line_break  
    puts `git checkout master`
    puts "Pulling changes:"
    puts `git pull`
    if opts[:branch]
      branch = opts[:branch]
    else  
      puts "Please enter a new git branch name for your changes (branch will be created):"
      branch = STDIN.gets.chomp
    end

    # Make sure new local branch does not already exist.
    if Git.branches.find { |e| /#{branch}/ =~ e }
      puts "There is already a local branch called #{branch}. [Q]uit or [U]se this branch"
      if STDIN.gets.chomp == 'U'
        Git.change_to_branch(branch)
      else
        puts "Exiting..."
        exit
      end
    else
      Git.new_branch(branch)
    end
    puts "Happy coding! Run stagecoach -d when you're ready to deploy."
  end

  if opts[:deploy]
    # Planio issue link-up.
    loop do
      if issue_number = config["issue_number"]
        puts "Current plan.io issue is #{issue_number}."
      else
        begin
          puts "Enter planio issue number:"
          issue_number = STDIN.gets.chomp
          raise ArgumentError.new('Invalid entry, try again') if issue_number =~ (/\D/)
        rescue ArgumentError => e
          puts e.message
          redo
        end
        begin
          puts "Searching for issue number #{issue_number}..."
          @issue = Redmine.issue(issue_number)
          puts "Issue found: #{@issue.subject} \n" 
        rescue ActiveResource::ResourceNotFound => e
          puts e.message
          redo
        end
      end
      puts "Is this correct? [Y]es or enter correct issue number:"
      response = STDIN.gets.chomp
      if response == 'Y'
        @issue = Redmine.issue(issue_number)
        config["issue_number"] = issue_number
        Config.save(config, config_file)
        break
      elsif response =~ /\d+/
        config["issue_number"] = response
        Config.save(config, config_file)
      end
      redo
    end

    # Create a Github issue referencing the planio issue.
    puts "Creating Git issue with subject: " + @issue.subject

    body = "Planio issue: #{Redmine.issue_url(@issue)} \n\n #{@issue.description}"

    console_output =  Git.new_issue(@issue.subject, body)
    github_issue_id = console_output[/\d+/]
    puts "Would you like to edit the issue on Github? [Y]es or [N]o"
    if STDIN.gets.chomp == 'Y'
      `open #{Git.view_issue(github_issue_id)}` 
      puts "Hit any key once you are done editing to continue"
      sleep unless STDIN.gets.chomp
    else
    end

    # Make sure this is the correct git branch.
    loop do
      puts "You are currently in local branch: #{Git.current_local_branch.red} \nIs this correct? ([Y]es or [N]o):"
      if STDIN.gets.chomp == "Y"
        break
      else
        puts "Which local branch would you like to be in?"
        Git.branches.each do |b|
          n = Git.branches.index(b)
          puts "#{n}.  " + b
        end
        @desired_branch = Git.branches[STDIN.gets.chomp.to_i]
        if @desired_branch =~ /\*/
          Git.change_to_branch(@desired_branch[1..-1])
        else
          Git.change_to_branch(@desired_branch)
        end
      end
    end

    # Get things rolling,  if everything else is OK.
    puts "Continue? Type 'push' to start script or anything else to cancel:"
    unless STDIN.gets.chomp == 'push'
      exit
    end

    CommandLine.line_break
    puts "Pushing your changes to branch '#{branch}'"
    puts `git push origin #{branch}`
    CommandLine.line_break
    puts "Merging into staging (after pull updates)"
    Git.change_to_branch("staging")
    puts `git pull origin staging`
    puts `git merge #{branch}`
    CommandLine.line_break
    puts "Pushing to staging"
    puts `git push origin staging`
    CommandLine.line_break
    puts "Deploying staging"
    puts `bundle exec cap staging deploy`
    puts "Changing to master branch"
    Git.change_to_branch("master")
    CommandLine.line_break
    puts "Attempting to change Planio ticket status to 'Feedback' for you"
    @issue.status.id = 4
    @issue.save
    Redmine.test_issue
  end
end
