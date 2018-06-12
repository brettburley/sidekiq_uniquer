require 'sidekiq_uniquer/strategy'

module SidekiqUniquer
  module Strategies
    # This strategy allows any number of jobs to be enqueued, but only allows one to be
    # executed at a time. Other jobs will have to wait for a lock if the lock_timeout option
    # is non-zero, or will be discarded if timeout is zero (default).
    class WhileExecuting
      include Strategy

      def push
        yield
      end

      def perform
        process_lock.lock do
          yield
        end
      rescue SidekiqUniquer::LockTimeout
        raise unless options[LOCK_TIMEOUT_KEY] == 0
        SidekiqUniquer.logger.info "SidekiqUniquer not performing non-unique job #{job[JOB_ID_KEY]} (#{job[JOB_CLASS_KEY]})."
      end
    end
  end
end
