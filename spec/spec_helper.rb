require 'rspec'
require 'sidekiq_uniquer'

require 'support/job_context'
require 'support/lock_mocks_context'
require 'support/sidekiq'

RSpec.configure do |config|
  config.before(:each, type: :integration) do
    Sidekiq::Worker.clear_all
    SidekiqUniquer.redis do |conn|
      keys = conn.keys("#{SidekiqUniquer::REDIS_PREFIX}:*")
      conn.del(keys) if keys.count > 0
    end

    WhileExecutingWorker.reset_count
  end
end