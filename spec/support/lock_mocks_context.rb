RSpec.shared_context 'lock mocks' do
  let(:job_lock) { double(SidekiqUniquer::RedisLock) }
  let(:process_lock) { double(SidekiqUniquer::RedisLock) }

  before do
    allow(SidekiqUniquer::RedisLock).to receive(:new)
      .with(/job:/, any_args)
      .and_return(job_lock)

    allow(SidekiqUniquer::RedisLock).to receive(:new)
      .with(/process:/, any_args)
      .and_return(process_lock)
  end
end
