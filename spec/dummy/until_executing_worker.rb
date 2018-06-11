class UntilExecutingWorker
  include Sidekiq::Worker

  sidekiq_options unique: :until_executing, lock_expiration: 10

  def perform(id)
    sleep 1
  end
end
