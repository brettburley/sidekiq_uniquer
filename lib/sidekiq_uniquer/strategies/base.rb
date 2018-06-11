module SidekiqUniquer
  module Strategies
    class Base
      attr_reader :job, :job_digest, :worker_class

      def initialize(job)
        @job = job
        @job_digest = JobDigest.digest(job)
        @worker_class = Object.const_get(job[JOB_CLASS_KEY])
      end

      private

      # A lock that is owned by the job itself. It can be unlocked by any process
      # that has the job. Useful for queue locking.
      def job_lock
        @job_lock ||= begin
          expires = options[LOCK_EXPIRATION_KEY]
          expires += job[JOB_AT_KEY].to_i - Time.now.to_i if job.has_key?(JOB_AT_KEY)

          RedisLock.new("job:#{job_digest}", job[JOB_ID_KEY],
            expires: expires,
            timeout: options[LOCK_TIMEOUT_KEY]
          )
        end
      end

      # A lock that is owned by the process. It can only be unlocked by the same
      # process. Useful for runtime locking.
      def process_lock
        @process_lock ||= begin
          RedisLock.new("process:#{job_digest}", ProcessDigest.digest,
            timeout: options[LOCK_TIMEOUT_KEY],
            expires: options[LOCK_EXPIRATION_KEY]
          )
        end
      end

      def options
        @options ||=
          {
            LOCK_EXPIRATION_KEY => SidekiqUniquer.config.default_lock_expiration,
            LOCK_TIMEOUT_KEY => SidekiqUniquer.config.default_lock_timeout
          }.merge(worker_class.get_sidekiq_options).merge(job)
      end
    end
  end
end
