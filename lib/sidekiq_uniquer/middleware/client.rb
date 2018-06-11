module SidekiqUniquer
  module Middleware
    class Client
      def call(worker_class, job, _queue, _redis_pool)
        klass = worker_class.is_a?(String) ? Object.const_get(worker_class) : worker_class
        strategy = Strategies.from(job, klass)

        if strategy.nil?
          yield
        else
          result = strategy.push { yield }
          SidekiqUniquer.logger.info "SidekiqUniquer not pushing non-unique job #{job[JOB_ID_KEY]} (#{job[JOB_CLASS_KEY]})." unless result
          result
        end
      end
    end
  end
end
