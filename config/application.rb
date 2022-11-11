# frozen_string_literal: true

require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

require_relative "../lib/log/logger"
module Maintenance
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 6.1

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")

    # Enable ougai
    if Rails.env.development? || Rails.const_defined?(:Console)
      config.logger = Log::Logger.new($stdout)
    elsif !Rails.env.test? # use default logger in test env
      config.logger = Log::Logger.new(Rails.root.join("log", "datadog.log"))
    end
  end
end
