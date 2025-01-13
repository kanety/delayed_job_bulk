# frozen_string_literal: true

module Delayed
  module Backend
    class Bulk
      module EnqueueAll
        def enqueue_all(jobs)
          Delayed::Backend::Bulk.enqueue(jobs).size
        end
      end
    end
  end
end

ActiveSupport.on_load :active_job do
  ActiveJob::QueueAdapters::DelayedJobAdapter.include Delayed::Backend::Bulk::EnqueueAll
end
