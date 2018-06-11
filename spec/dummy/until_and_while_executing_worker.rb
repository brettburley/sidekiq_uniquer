class UntilAndWhileExecutingWorker
  include Sidekiq::Worker

  sidekiq_options unique: :until_and_while_executing

  def perform(id)
    sleep 1
  end
end
