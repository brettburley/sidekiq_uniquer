module SidekiqUniquer
  module Strategies
    # This strategy locks a job until it has successfully executed. If a job raises
    # it will not unlock until it retries and subsequently succeeds, or the lock
    # times out.
    class UntilExecuted < Base
      def push
        return false unless job_lock.lock
        yield
      end

      def perform
        yield
        job_lock.unlock
      end
    end
  end
end
