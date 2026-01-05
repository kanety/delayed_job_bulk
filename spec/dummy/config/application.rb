require_relative 'boot'

require 'active_record/railtie'
require 'active_job/railtie'

Bundler.require(*Rails.groups)
require 'delayed_job_bulk'

module Dummy
  class Application < Rails::Application
    config.load_defaults Rails::VERSION::STRING.to_f

    # fix "NameError: uninitialized constant ActiveJob::QueueAdapters::AbstractAdapter" with rails < 7.2 and delayed_job 4.2
    if ActiveJob.version < Gem::Version.new('7.2.0')
      spec = Gem::Specification.find_by_name('activejob')
      require File.join(spec.gem_dir, 'lib/active_job/queue_adapters/delayed_job_adapter')
    end

    config.active_job.queue_adapter = :delayed_job

    if ENV['DATABASE'].in?(%w(postgresql mysql))
      config.paths["config/database"] = "config/database_#{ENV['DATABASE']}.yml"
    end
  end
end
