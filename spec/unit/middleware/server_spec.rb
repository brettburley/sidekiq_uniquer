require 'spec_helper'

RSpec.describe SidekiqUniquer::Middleware::Server do
  subject(:middleware) { described_class.new }

  describe '#call' do
    let(:job) { double('job') }
    let(:worker_class) { Class.new }
    let(:worker) { worker_class.new }

    before do
      allow(SidekiqUniquer::Strategies).to receive(:from).with(job, worker_class)
        .and_return(strategy)
    end

    context 'with no strategy' do
      let(:strategy) { nil }

      it 'yields the job' do
        expect { |b| middleware.call(worker, job, :default, &b) }.to yield_control
      end
    end

    context 'with a strategy' do
      let(:strategy) { double('strategy') }

      it 'yields to the strategy' do
        yielded = false

        expect(strategy).to receive(:perform) do |&block|
          expect(yielded).to eq(false)
          block.call
          expect(yielded).to eq(true)
        end

        middleware.call(worker, job, :default) do
          yielded = true
        end
      end
    end
  end
end