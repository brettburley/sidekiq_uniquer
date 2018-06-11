module SidekiqUniquer
  module Middleware
    class Server
      def call(worker, job, _queue)
        strategy = Strategies.from(job, worker.class)

        if strategy.nil?
          yield
        else
          strategy.perform { yield }
        end
      end
    end
  end
end
