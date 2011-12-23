class Stagecoach::Redmine
  def self.issue(issue_number)
    return RedmineClient::Issue.find(issue_number)
  end

  def self.issue_url(issue)
    RedmineClient::Base.site + "/issues/" + issue.id
  end
end
