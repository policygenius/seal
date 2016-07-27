require 'octokit'
require 'json'

class GithubFetcher
  ORGANISATION ||= ENV['SEAL_ORGANISATION']
  REPOS ||= ENV['PG_REPOS'] ? JSON.parse(ENV['PG_REPOS']) : ['policygenius']

  attr_accessor :people, :repo, :github

  def initialize(team_members_accounts, use_labels, exclude_labels, exclude_titles, repo: nil)
    @github = Octokit::Client.new(:access_token => ENV['GITHUB_TOKEN'])
    github.user.login
    Octokit.auto_paginate = true
    @people = team_members_accounts
    @use_labels = use_labels
    @exclude_labels = exclude_labels.map(&:downcase).uniq if exclude_labels
    @exclude_titles = exclude_titles.map(&:downcase).uniq if exclude_titles
    @labels = {}
    @repo = repo
  end

  def list_pull_requests
    pull_requests_from_github.each_with_object({}) do |pull_request, pull_requests|
      repo_name = pull_request.html_url.split("/")[4]

      # if repo is given, return only prs that belong to the repo
      if repo
        next unless repo == repo_name
      end

      next if hidden?(pull_request, repo_name)
      pull_requests[pull_request.title] = present_pull_request(pull_request, repo_name)
    end
  end

  def list_percy_builds
    github
      .search_issues("is:pr state:open user:policygenius")
      .items
      .map { |g| [g[:repository_url].gsub(/.*repos\//, ''), g[:number], g[:title]] }
      .map { |repo, number, title| [repo, github.pull_request_commits(repo, number).first[:sha], title] }
      .select { |repo, sha, title| !title.include?('WIP') }
      .map { |repo, sha, title| [github.statuses(repo, sha), title] }
      .map { |statuses, title| [statuses.select { |s| s[:context] == 'percy' }.first, title] }
      .select { |status, title| status && status[:description] == "Visual diffs found!" }
      .map { |status, title| [title, status[:target_url]] }
  end

  private

  attr_reader :use_labels, :exclude_labels, :exclude_titles

  def present_pull_request(pull_request, repo_name)
    pr = {}
    pr['title'] = pull_request.title
    pr['link'] = pull_request.html_url
    pr['author'] = pull_request.user.login
    pr['repo'] = repo_name
    pr['comments_count'] = count_comments(pull_request, repo_name)
    pr['thumbs_up'] = count_thumbs_up(pull_request, repo_name)
    pr['updated'] = Date.parse(pull_request.updated_at.to_s)
    pr['labels'] = labels(pull_request, repo_name)
    pr
  end

  def pull_requests_from_github
    github.search_issues("is:pr state:open user:#{ORGANISATION}").items
  end

  def person_subscribed?(pull_request)
    people.empty? || people.include?("#{pull_request.user.login}")
  end

  def count_comments(pull_request, repo)
    pr = github.pull_request("#{ORGANISATION}/#{repo}", pull_request.number)
    (pr.review_comments + pr.comments).to_s
  end

  def count_thumbs_up(pull_request, repo)
    response = github.issue_comments("#{ORGANISATION}/#{repo}", pull_request.number)
    comments_string = response.map {|comment| comment.body}.join
    thumbs_up = comments_string.scan(/:\+1:/).count.to_s
  end

  def labels(pull_request, repo)
    return [] unless use_labels
    key = "#{ORGANISATION}/#{repo}/#{pull_request.number}".to_sym
    @labels[key] ||= github.labels_for_issue("#{ORGANISATION}/#{repo}", pull_request.number)
  end

  def hidden?(pull_request, repo)
    excluded_label?(pull_request, repo) || excluded_title?(pull_request.title) || !person_subscribed?(pull_request)
  end

  def excluded_label?(pull_request, repo)
    return false unless exclude_labels
    lowercase_label_names = labels(pull_request, repo).map { |l| l['name'].downcase }
    exclude_labels.any? { |e| lowercase_label_names.include?(e) }
  end

  def excluded_title?(title)
    exclude_titles && exclude_titles.any? { |t| title.downcase.include?(t) }
  end
end
