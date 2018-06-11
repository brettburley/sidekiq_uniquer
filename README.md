# SidekiqUniquer
A gem that extends sidekiq to enable unique jobs that are locked in redis.

## Usage
This gem works with both plain ruby and rails projects using sidekiq. After installing this gem, you can modify your existing worker classes to enforce uniqueness by adding a `unique` key to the worker's `sidekiq_options`.

```ruby
class MyWorker
  include Sidekiq::Worker

  sidekiq_options unique: :until_executed

  def perform(id)
    # Worker code here...
  end
end
```

There are 4 uniqueness strategies available for different use cases:

* `until_and_while_executing` - locks a job until it has started executing, at which point a new job is allowed to be queued. However, the job is still locked at execution time to ensure that only a single job is executed simultaneously.
* `until_executed` - locks a job until it has successfully executed. If a job raises it will not unlock until it retries and subsequently succeeds, or the lock times out.
* `until_executing` - locks a job until it begins processing. Once the job starts running, another will be allowed to be enqueued. It does not guarantee that the two jobs will not run simultaneously.
* `while_executing` - allows any number of jobs to be enqueued, but only allows one to be executed at a time. Other jobs will have to wait for a lock if the lock_timeout option is non-zero, or will be discarded if timeout is zero (default).

## Installation
Add this line to your application's Gemfile:

```ruby
gem 'sidekiq_uniquer'
```

And then execute:
```bash
$ bundle
```

Or install it yourself as:
```bash
$ gem install sidekiq_uniquer
```

If you want to override any of the default confiration that is provided, you can call the `configure` method from an initializer or during your app initialization process.

```ruby
SidekiqUniquer.configure do |c|
  c.default_lock_expiration = 5.minutes
  c.default_lock_timeout = 10.seconds
  c.logger = Rails.logger
end
```

## Contributing
TBD

## License
The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
