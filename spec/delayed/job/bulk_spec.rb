describe Delayed::Job::Bulk do
  context 'basic' do
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
  end

  if Rails::VERSION::STRING.to_f >= 7.0
    context 'run_at' do
      let :active_jobs do
        10.times.map { |i| TestJob.new("test_#{i}").set(wait_until: Time.parse('2025-01-01 10:20:00') + i.minutes) }
      end

      before do
        Delayed::Job.delete_all
      end

      it 'enqueues jobs with run_at' do
        jobs = Delayed::Job::Bulk.enqueue(active_jobs)
        expect(jobs.size).to eq(10)
        expect(Delayed::Job.order(:run_at).first.run_at).to eq(Time.parse('2025-01-01 10:20:00'))
        expect(Delayed::Job.order(:run_at).second.run_at).to eq(Time.parse('2025-01-01 10:21:00'))
      end
    end
  end

  if ENV['DATABASE'] == 'postgresql'
    context 'postgresql' do
      let :active_jobs do
        10.times.map { |i| TestJob.new("test_#{i}") }
      end
  
      before do
        Delayed::Job.delete_all
      end

      it 'sets id to each job for postgresql' do
        jobs = Delayed::Job::Bulk.enqueue(active_jobs)
        expect(active_jobs[0].provider_job_id).not_to eq(nil)
        expect(active_jobs[1].provider_job_id).not_to eq(nil)
        expect(jobs[0].id).not_to eq(nil)
        expect(jobs[1].id).not_to eq(nil)
      end
    end
  end
end
