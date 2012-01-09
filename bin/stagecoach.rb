#! usr/bin/env ruby
# encoding: utf-8
require '../lib/stagecoach.rb'

module Stagecoach
  # Set up configuration variables
  config = Config.yaml_to_hash
  config_file = Config.open

  # Set up redmine_client config 
  RedmineClient::Base.configure do
    self.site = config["redmine_site"]
    self.user = config["redmine_api_key"]
    self.password = 'no_password_needed_with_api_key'
  end


  # Planio issue link-up 
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

  # Create a Github issue referencing the planio issue
  puts "Creating Git issue with subject: " + @issue.subject
  puts "#Testing: Push enter to create or anything else to continue without creating an issue"
  body = "Planio issue: #{Redmine.issue_url(@issue)} \n\n #{@issue.description}"

  console_output =  Git.new_issue(@issue.subject, body) if STDIN.gets == "\n"
  github_issue_id = console_output[/\d+/]
  puts "Would you like to edit the issue on Github? [Y]es or [N]o"

  `open #{Git.view_issue(github_issue_id)}` if STDIN.gets.chomp == 'Y'

  puts "Hit any key once you are done editing to continue"
  sleep unless STDIN.gets.chomp

  # Create a local git branch for this issue
  loop do
    Git.current_local_branch
    puts "Please enter a local branch name for issue: \"#{@issue.subject}\""
    new_local_branch = STDIN.gets.chomp
    Git.branches.select do |v| 
      if v =~ /#{new_local_branch}/
        puts "There is already a local branch called #{new_local_branch}. [R]edo or [U]se this branch"
        redo unless gets.chomp == 'R'
      end
    end
    Git.change_to_branch(new_local_branch)
    break
  end

# Make sure this is the correct git branch
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
      `git checkout #{@desired_branch[1..-1]}`
    else
      `git checkout #{@desired_branch}`
    end
  end
end

# Create a remote git branch
puts "Enter new remote branch name (eg. #{Git.current_local_branch}):"
branch = STDIN.gets.strip

# Get things rolling,  if everything else is OK.
puts "Continue? Type 'push' to start script or anything else to cancel:"
unless STDIN.gets.chomp == 'push'
  exit
end

line_break
puts "Pushing your changes to branch '#{branch}'"
puts `git push origin #{@local_branch}:#{branch}`
line_break
puts "Merging into staging (after pull updates)"
puts `git checkout staging`
puts `git pull origin staging`
puts `git merge #{branch}`
line_break
puts "Pushing to staging"
puts `git push origin staging`
line_break
puts "Deploying staging"
puts `bundle exec cap staging deploy`
puts `git checkout master`
line_break
puts "Attempting to change Planio ticket status to 'Feedback' for you"
@issue.status.id = 4
@issue.save
Redmine.test_issue
end
