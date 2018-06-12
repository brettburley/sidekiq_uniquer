require 'sidekiq_uniquer/job_digest'
require 'sidekiq_uniquer/middleware'
require 'sidekiq_uniquer/process_digest'
require 'sidekiq_uniquer/redis_lock'
require 'sidekiq_uniquer/strategies'
require 'sidekiq_uniquer/strategy'
require 'sidekiq_uniquer/version'

module SidekiqUniquer
  LockTimeout = Class.new(StandardError)
  UnknownStrategy = Class.new(StandardError)

  JOB_ARGS_KEY = 'args'
  JOB_AT_KEY = 'at'
  JOB_CLASS_KEY = 'class'
  JOB_DIGEST_KEY = 'uniquer_digest'
  JOB_ID_KEY = 'jid'
  JOB_QUEUE_KEY = 'queue'
  JOB_STRATEGY_KEY = 'unique'
  LOCK_EXPIRATION_KEY = 'lock_expiration'
  LOCK_TIMEOUT_KEY = 'lock_timeout'
  REDIS_PREFIX = 'sidekiquniquer'

  module_function

  def config
    @config ||= OpenStruct.new(
      default_lock_expiration: 60,
      default_lock_timeout: 0,
      logger: Logger.new(File::NULL),
      redis_pool: nil
    )
  end

  def configure
    yield config
  end

  def logger
    config.logger
  end

  def redis(&block)
    config.redis_pool || Sidekiq.redis(&block)
  end
end