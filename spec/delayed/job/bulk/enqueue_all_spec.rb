if Rails::VERSION::STRING.to_f >= 7.1
  describe Delayed::Job::Bulk::EnqueueAll do
    let :active_jobs do
      10.times.map { |i| TestJob.new("test_#{i}") }
    end

    before do
      Delayed::Job.delete_all
    end

    it 'enqueues multiple jobs via ActiveJob' do
      ActiveJob.perform_all_later(active_jobs)
      expect(Delayed::Job.count).to eq(10)

      in_args = active_jobs.map { |job| job.arguments[0] }
      out_args = Delayed::Job.order(:id).map { |job| job.payload_object.job_data['arguments'][0] }
      expect(in_args).to eq(out_args)
    end
  end
end
