require 'rubygems'
require 'redmine_client'

module Stagecoach
  class Redmine
    def self.issue(issue_number)
      return RedmineClient::Issue.find(issue_number)
    end

    def self.issue_url(issue)
      RedmineClient::Base.site + "/issues/" + issue.id
    end

    # API testing - can be removed once the redmine API supports changing of
    # issue status, currently this is broken.
    # More information at http://www.redmine.org/boards/2/topics/25920
    def self.test_issue(issue)
      issue_url = Redmine.issue_url(issue)
      issue_hash = issue.status.attributes
      if issue_hash['name'] == 'Feedback'
        puts 'Feedback changed successfully!'
        puts "View issue: #{issue_url}"
      else
        puts "Sorry, the Redmine API doesn't currently support changing of issue status via API.  Please change it manually:"
        puts issue_url
        puts "Open in browser? [Y]es/[N]o"
        open issue_url.to_s if gets.chomp == "Y"
        puts "Staging completed!  Exiting..."
      end
    end
  end
end
