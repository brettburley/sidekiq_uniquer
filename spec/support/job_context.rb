RSpec.shared_context 'job' do
  let(:job) do
    {
      'class' => 'TestJobClass',
      'queue' => 'default'
    }
  end

  let(:job_class) { double('TestJobClass', get_sidekiq_options: options) }
  let(:options) { {} }

  before do
    # Sidekiq and this gem look up classes by string when hydrating from a job
    # hash, so they require the class being registered.
    stub_const 'TestJobClass', job_class
  end
end
