require 'spec_helper'

RSpec.describe SidekiqUniquer::Strategies do
  include_context 'job'

  describe '.from' do
    context 'with no job strategy' do
      let(:options) { {} }

      it 'returns nil' do
        expect(described_class.from(job, job_class)).to eq(nil)
      end
    end

    context 'with an unknown job strategy' do
      let(:options) { { 'unique' => 'foo' } }

      it 'raises an error' do
        expect { described_class.from(job, job_class) }.to raise_error(SidekiqUniquer::UnknownStrategy)
      end
    end

    context 'with a known job strategy' do
      let(:options) { { 'unique' => :until_and_while_executing } }

      it 'instatiates the strategy with the job' do
        strategy = described_class.from(job, job_class)
        expect(strategy).to be_a(SidekiqUniquer::Strategies::UntilAndWhileExecuting)
        expect(strategy.job).to eq(job)
      end
    end
  end
end