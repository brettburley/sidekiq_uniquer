require 'json'

module SidekiqUniquer
  # Converts a Sidekiq job hash into a digest string to uniquely identify the
  # combination of job class, arguments, and queue for uniqueness.
  class JobDigest
    attr_reader :job

    def initialize(job)
      @job = job
    end

    def digest
      job[JOB_DIGEST_KEY] ||= Digest::MD5.hexdigest(JSON.generate(digest_params))
    end

    def self.digest(*args)
      new(*args).digest
    end

    private

    def digest_params
      {
        'args' => job[JOB_ARGS_KEY],
        'class' => job[JOB_CLASS_KEY],
        'queue' => job[JOB_QUEUE_KEY]
      }
    end
  end
end