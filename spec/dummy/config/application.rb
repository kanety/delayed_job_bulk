require_relative 'boot'

require 'active_record/railtie'
require 'active_job/railtie'

Bundler.require(*Rails.groups)
require 'delayed_job_bulk'

module Dummy
  class Application < Rails::Application
    config.load_defaults Rails::VERSION::STRING.to_f

    config.active_job.queue_adapter = :delayed_job

    if ENV['DATABASE'].in?(%w(postgresql mysql))
      config.paths["config/database"] = "config/database_#{ENV['DATABASE']}.yml"
    end
  end
end
