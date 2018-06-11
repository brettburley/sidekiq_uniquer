require 'spec_helper'

RSpec.describe SidekiqUniquer::ProcessDigest do
  describe '.digest' do
    it 'returns the correct digest' do
      expect(described_class.digest).to eq(
        "#{Socket.gethostname}:#{Process.pid}:#{Thread.current.object_id}"
      )
    end
  end
end