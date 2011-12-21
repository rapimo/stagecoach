#!/usr/bin/env ruby

require 'rubygems'
require 'redmine_client'
require 'yaml'

config = YAML::load(File.open('config.yaml'))

RedmineClient::Base.configure do
  self.site = config[ "redmine_site" ]
  self.user = config[ "redmine_api_key" ]
  self.password = 'test'
end

line_break = "-" * 50

ARGV.each do |input|
  issue_number = input
  issue = RedmineClient::Issue.find(issue_number)
  puts line_break
  puts "Subject: #{issue.subject}"
  puts line_break
  puts issue.description
  puts line_break
  puts "Created by #{issue.author.name}"
  puts "Assigned to #{issue.assigned_to.name}"
  puts line_break
#  issue.attributes.each do |key, value|
#    puts "#{key.to_s} = #{value.to_s}"
#  end
end
