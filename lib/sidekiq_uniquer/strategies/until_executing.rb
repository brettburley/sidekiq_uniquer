module SidekiqUniquer
  module Strategies
    # This strategy locks a job until it begins processing. Once the job starts running,
    # another will be allowed to be enqueued. It does not guarantee that the two jobs will
    # not run simultaneously.
    class UntilExecuting < Base
      def push
        return false unless job_lock.lock
        yield
      end

      def perform
        job_lock.unlock
        yield
      end
    end
  end
end
