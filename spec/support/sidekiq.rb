require 'sidekiq/testing'

Sidekiq::Testing.server_middleware do |chain|
  chain.add(SidekiqUniquer::Middleware::Server)
end
