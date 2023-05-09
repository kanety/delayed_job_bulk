describe Delayed::Job::Bulk do
  let :active_jobs do
    10.times.map { |i| TestJob.new("test_#{i}") }
  end

  before do
    Delayed::Job.delete_all
  end

  it 'enqueues jobs' do
    jobs = Delayed::Job::Bulk.enqueue(active_jobs)
    expect(jobs.size).to eq(10)
    expect(jobs[0].payload_object.job_data['arguments'][0]).to eq("test_0")
    expect(jobs[1].payload_object.job_data['arguments'][0]).to eq("test_1")
  end

  if ENV['DATABASE'] == 'postgresql'
    it 'sets id to each job for postgresql' do
      jobs = Delayed::Job::Bulk.enqueue(active_jobs)
      expect(active_jobs[0].provider_job_id).not_to eq(nil)
      expect(active_jobs[1].provider_job_id).not_to eq(nil)
      expect(jobs[0].id).not_to eq(nil)
      expect(jobs[1].id).not_to eq(nil)
    end
  end

  context 'callbacks' do
    it 'calls before_enqueue' do
      job_ids = []
      Delayed::Job::Bulk.before_enqueue do
        job_ids = @jobs.map { |job| job.payload_object.job_data['job_id'] }
      end
      Delayed::Job::Bulk.enqueue(active_jobs)
      expect(active_jobs.map(&:job_id)).to eq(job_ids)
    end

    it 'calls after_enqueue' do
      job_ids = []
      Delayed::Job::Bulk.after_enqueue do
        job_ids = @jobs.map { |job| job.payload_object.job_data['job_id'] }
      end
      Delayed::Job::Bulk.enqueue(active_jobs)
      expect(active_jobs.map(&:job_id)).to eq(job_ids)
    end

    it 'calls around_enqueue' do
      job_ids = []
      Delayed::Job::Bulk.around_enqueue do |bulk, block|
        block.call
        job_ids = @jobs.map { |job| job.payload_object.job_data['job_id'] }
      end
      Delayed::Job::Bulk.enqueue(active_jobs)
      expect(active_jobs.map(&:job_id)).to eq(job_ids)
    end
  end
end
