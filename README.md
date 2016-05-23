# Seal
[![Build Status](https://semaphoreci.com/api/v1/policygenius/seal/branches/master/badge.svg)](https://semaphoreci.com/policygenius/seal)

##What is it?

This is a Slack bot that publishes a team's pull requests to their Slack Channel, once provided the organisation name, the team members' github names, and a list of repos to follow. It is my first 20% project at GDS.

![image](https://github.com/binaryberry/seal/blob/master/images/readme/informative.png)
![image](https://github.com/binaryberry/seal/blob/master/images/readme/angry.png)

##How to use it?
Fork the repo, and change the config file to put: your team's name, the github names of your team members, the list of repos to follow, and the Slack channel you want to post to.

In your shell profile, put in:

```sh
export SEAL_ORGANISATION="your_github_organisation"
export GITHUB_TOKEN="get_your_github_token_from_yourgithub_settings"
export SLACK_WEBHOOK="get_your_incoming_webhook_link_for_your_slack_group_channel"
```

- To get a new `GITHUB_TOKEN`, head to: https://github.com/settings/tokens
- To get a new `SLACK_WEBHOOK`, head to: https://slack.com/services/new/incoming-webhook

To test the script locally, go to Slack and create a channel or private group called "#angry-seal-bot-test". Then run `./bin/seal.rb your_team_name` in your command line, and you should see the post in the #angry-seal-bot-test channel. If you don't want to post github pull requests but a random quote from your team's quotes config, run `./bin/seal.rb your_team_name quotes`

You should also set up the following custom emojis in Slack:
- :informative_seal:
- :angrier_seal:
- :seal_of_approval:
- :happyseal:
- :halloween_informative_seal:
- :halloween_angrier_seal:
- :halloween_seal_of_approval:
- :festive_season_informative_seal:
- :festive_season_angrier_seal:
- :festive_season_seal_of_approval:
- :manatea:

You can use the images in images/emojis that have the corresponding names.

When that works, you can push the app to Heroku, add the GITHUB_TOKEN and SLACK_WEBHOOK environment variables to heroku, and use the Heroku scheduler add-on to create repeated rasks - I set the seal to run at 9.30am every morning (the seal won't post on weekends)

Any questions feel free to contact me on Twitter -  my handle is binaryberry

## Deploy to Heroku

[![Deploy](https://www.herokucdn.com/deploy/button.png)](https://heroku.com/deploy)

##How to run the tests?
Just run `rspec` in the command line


## Tips

How to list your organisation's repositories modified within the last year:

In `irb`, from the folder of the project, run:

```ruby
require 'octokit'
github = Octokit::Client.new(:access_token => ENV['GITHUB_TOKEN'], auto_pagination: true)
response = github.repos(org: ENV['SEAL_ORGANISATION'])
repo_names = response.select { |repo| Date.parse(repo.updated_at.to_s) > (Date.today - 365) }.map(&:name)
```

## CRC

Github fetcher:
- queries Github's API

Message Builder:
- produces message from Github API's content

Slack Poster:
- posts message to Slack

Trello board: https://trello.com/b/sgakJmlY/moody-seal

## License

See the [LICENSE](LICENSE) file for license rights and limitations (MIT).
