# DelayedJobBulk

Bulk insert many jobs at once for delayed_job.

## Dependencies

* ruby 3.0+
* activerecord 7.0+
* delayed_job 4.1+
* delayed_job_active_record 4.1

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'delayed_job_bulk'
```

And then execute:

    $ bundle

## Usage

Build `ActiveJob::Base` instances and pass them to `Delayed::Job::Bulk.enqueue`:

```ruby
class SampleJob < ActiveJob::Base
end

active_jobs = 10.times.map { SampleJob.new('sample') }
jobs = Delayed::Job::Bulk.enqueue(active_jobs)
```

Return value of `Delayed::Job::Bulk.enqueue` is an array of Delayed::Job instance:

```ruby
jobs.size #=> 10
jobs.each do |job|
  job.id  #=> 12345 (id is set only postgresql)
end
```

### Caveats

Callbacks related with ActiveJob (`before_enqueue`, `after_enqueue` and `around_enqueue`) are not called for bulk enqueue.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/kanety/delayed_job_bulk.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
