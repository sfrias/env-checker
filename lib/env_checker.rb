$LOAD_PATH.unshift(File.dirname(__FILE__))

require 'yaml'
require 'env_checker/version'
require 'env_checker/missing_keys_error'
require 'env_checker/configuration'
require 'env_checker/cli'
require 'env_checker/notifier'

module EnvChecker
  class << self
    attr_accessor :configurations

    def configure
      self.configurations ||= {}
      configurations['global'] = Configuration.new
      yield(configurations['global'])
      after_configure_and_check
    end

    def cli_configure_and_check(options)
      self.configurations = create_config_from_parameters(options)
      after_configure_and_check
    end

    private

    def after_configure_and_check
      environments_to_check = %w(global)

      current_env = configurations['global'].environment
      if current_env && configurations.key?(current_env)
        environments_to_check << current_env
      end

      environments_to_check.map do |env|
        configurations[env].after_initialize

        check_optional_variables(env) & check_required_variables(env)
      end.reduce(:&)
    end

    def create_config_from_parameters(options)
      configurations = { 'global' => Configuration.new }

      if options[:config_file]
        from_file = YAML.load_file(options[:config_file])

        options_to_config(configurations['global'], from_file)
        if configurations['global'].environments.any?
          configurations['global'].environments.each do |env|
            configurations[env] = Configuration.new
            options_to_config(configurations[env], from_file[env] || {})
          end
        end
      end

      # Override parameters with CLI
      options_to_config(configurations['global'], options || {})
      configurations
    end

    def options_to_config(configuration, options)
      Configuration::ATTRIBUTES.each do |a|
        options[a] &&
          configuration.public_send("#{a}=", options[a])

        options[a.to_sym] &&
          configuration.public_send("#{a}=", options[a.to_sym])
      end
    end

    def check_optional_variables(env)
      missing_keys = missing_keys_env(configurations[env].optional_variables)
      return true if missing_keys.empty?

      Notifier.log_message(
        configurations[env],
        :warning,
        env,
        "Warning! Missing optional variables: #{missing_keys}"
      )

      false
    end

    def check_required_variables(env)
      missing_keys = missing_keys_env(configurations[env].required_variables)
      return true if missing_keys.empty?

      Notifier.log_message(
        configurations[env],
        :error,
        env,
        "Error! Missing required variables: #{missing_keys}"
      )

      raise MissingKeysError, missing_keys
    end

    def missing_keys_env(keys)
      return [] unless keys
      keys.flatten - ::ENV.keys
    end
  end
end
