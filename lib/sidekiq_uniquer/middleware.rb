require 'sidekiq_uniquer/middleware/client'
require 'sidekiq_uniquer/middleware/server'

require 'sidekiq'

Sidekiq.configure_server do |config|
  config.server_middleware do |chain|
    chain.add(SidekiqUniquer::Middleware::Server)
  end
  config.client_middleware do |chain|
    chain.add(SidekiqUniquer::Middleware::Client)
  end
end

Sidekiq.configure_client do |config|
  config.client_middleware do |chain|
    chain.add(SidekiqUniquer::Middleware::Client)
  end
end
