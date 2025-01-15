# frozen_string_literal: true

require_relative 'bulk/callbacks'
require_relative 'bulk/enqueue_all'

module Delayed
  module Backend
    class Bulk
      include Callbacks

      define_callbacks :enqueue

      def initialize(active_jobs)
        @active_jobs = Array(active_jobs)
      end

      def call
        @jobs = @active_jobs.map { |active_job| build_job(active_job) }
        @valid_jobs = @jobs.select(&:valid?)

        if @valid_jobs.present?
          @valid_jobs.each do |job|
            job.send(:set_default_run_at)
          end
          run_callbacks :enqueue do
            insert_all
          end
        end

        @valid_jobs
      end

      private

      def build_job(active_job)
        Delayed::Job.new(
          Delayed::Backend::JobPreparer.new(
            ActiveJob::QueueAdapters::DelayedJobAdapter::JobWrapper.new(active_job.serialize),
            queue: active_job.queue_name,
            priority: active_job.priority,
            run_at: build_run_at(active_job.scheduled_at)
          ).prepare
        ).tap do |job|
          job.created_at = current_time
          job.updated_at = current_time
        end
      end

      def build_run_at(scheduled_at)
        if scheduled_at.is_a?(Float)
          Time.at(scheduled_at)
        else
          scheduled_at
        end
      end

      def current_time
        @current_time ||= Time.zone.now
      end

      def insert_all
        attrs = @valid_jobs.map { |job| job.attributes.reject { |_,v| v.nil? } }
        result = Delayed::Job.insert_all(attrs)
        assign_id(result.rows) if result.rows.present?
      end

      def assign_id(ids)
        @valid_jobs.each_with_index do |job, i|
          job.id = ids[i][0]
          job.instance_variable_set('@new_record', false)
          job.instance_variable_set('@previously_new_record', true)
        end

        @jobs.size.times do |i|
          @active_jobs[i].provider_job_id = @jobs[i].id
        end
      end

      class << self
        def enqueue(active_jobs)
          new(active_jobs).call
        end
      end
    end
  end
end

Delayed::Job::Bulk = Delayed::Backend::Bulk
