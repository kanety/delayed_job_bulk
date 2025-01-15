describe Delayed::Job::Bulk::Callbacks do
  let :active_jobs do
    10.times.map { |i| TestJob.new("test_#{i}") }
  end

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
