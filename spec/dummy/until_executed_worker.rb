class UntilExecutedWorker
  include Sidekiq::Worker

  sidekiq_options unique: :until_executed

  def perform(id)
    sleep 1
  end
end
