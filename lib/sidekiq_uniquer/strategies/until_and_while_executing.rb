module SidekiqUniquer
  module Strategies
    # This strategy locks a job until it has started executing, at which point a new job
    # is allowed to be queued. However, the job is still locked at execution time to ensure
    # that only a single job is executed simultaneously.
    class UntilAndWhileExecuting < Base
      def push
        return false unless job_lock.lock
        yield
      end

      def perform
        process_lock.lock do
          job_lock.unlock
          yield
        end
      rescue SidekiqUniquer::LockTimeout
        raise unless options[LOCK_TIMEOUT_KEY] == 0
        SidekiqUniquer.logger.info "SidekiqUniquer not performing non-unique job #{job[JOB_ID_KEY]} (#{job[JOB_CLASS_KEY]})."
      end
    end
  end
end
