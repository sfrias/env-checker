# Env-checker

[![Gem Version](https://badge.fury.io/rb/env-checker.svg)](https://badge.fury.io/rb/env-checker)
[![Dependency Status](https://gemnasium.com/badges/github.com/ryanfox1985/env-checker.svg)](https://gemnasium.com/github.com/ryanfox1985/env-checker)
[![Build Status](https://travis-ci.org/ryanfox1985/env-checker.svg?branch=master)](https://travis-ci.org/ryanfox1985/env-checker)
[![Coverage Status](https://coveralls.io/repos/github/ryanfox1985/env-checker/badge.svg?branch=master)](https://coveralls.io/github/ryanfox1985/env-checker?branch=master)
[![Code Climate](https://codeclimate.com/github/ryanfox1985/env-checker/badges/gpa.svg)](https://codeclimate.com/github/ryanfox1985/env-checker)
[![license](https://img.shields.io/github/license/mashape/apistatus.svg)](https://github.com/ryanfox1985/env-checker/blob/master/LICENSE)


Don't forget your environment variables when your app changes the environment.
When you are developing a new feature if your app have some environments like
test, staging and production is easy to forget an environment variable in the
middle of the process. Also when you migrate the app to another server is easy
to forget an environment variable.  

You can define two variable lists:
- **required_variables:** These variables are mandatory (Your app cannot run
  without these variables, like `DATABASE_URL`)
- **optional_variables:** These variables are from secondary services (Your app
  can run without these variables, like some `THRESHOLD`)

By default `EnvChecker` checks the global environment and after the current
or set environment.

All the missing variables are notified by default in the `STDERR`. When a
required variable is missing the gem raises an error `MissingKeysError` and
stops the application.

By convention all the environment variable names must be in up case, the gem
internally parse the required_variables and optional_variables to up case.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'env-checker'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install env-checker


## Usage


### Rails or Ruby standalone

Create a initializer to configure the gem and run the hook to check the
environment variables. Example:

```ruby
# config/initializers/env_checker.rb

require 'env_checker'

EnvChecker.configure do |config|
  config.slack_webhook_url = 'https://hooks.slack.com/services/.../.../.../'
  config.optional_variables = %w(MyOptVar1 MyOptVar2)
  config.required_variables = %w(MyReqVar1 MyReqVar2)

  # ENVIRONMENT
  # ===========
  # Default is:
  # environment = ENV['RACK_ENV'] || ENV['RAILS_ENV']
  #
  # Other possible value
  # config.environment = 'MyEnv'  

  # LOGGER
  # ======
  # Default is:
  #
  # config.logger = Logger.new(STDERR)
  #
  # Some possible settings:
  # config.logger = Rails.logger                        # Log with all your app's other messages
  # config.logger = Logger.new('log/env_checker.log')   # Use this file
  # config.logger = Logger.new('/dev/null')             # Don't log at all (on a Unix system)
end
```


### Standalone and CLI usages

#### Check optional and required variables

Inline passing the variables with the shell:

```shell
$ env-checker check --optional MyOptVar1 MyOptVar2 --required MyReqVar1 MyReqVar2

Usage:
  env-checker check

Options:
  e, [--environment=ENVIRONMENT]
  cf, [--config-file=CONFIG_FILE]
  r, required, [--required-variables=one two three]
  o, optional, [--optional-variables=one two three]
  slack, [--slack-webhook-url=SLACK_WEBHOOK_URL]
          [--run=RUN]
```

- All the parameters can be set by environment variables like:

```shell
$ export ENV_CHECKER_ENVIRONMENT=staging
$ export ENV_CHECKER_REQUIRED_VARIABLES=one two three
$ export ENV_CHECKER_OPTIONAL_VARIABLES=one two three
$ export ENV_CHECKER_SLACK_WEBHOOK_URL=https://hooks.slack.com/services/.../.../.../
$ env-checker check
```

- Example with a `.yml` [example file](https://raw.githubusercontent.com/ryanfox1985/env-checker/master/sample_config.yml):

```shell
$ env-checker check --config_file sample_config.yml
```

#### Show help

    $ env-checker help

#### Show version

    $ env-checker version


## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/ryanfox1985/env-checker/issues and https://github.com/ryanfox1985/env-checker/pulls. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
