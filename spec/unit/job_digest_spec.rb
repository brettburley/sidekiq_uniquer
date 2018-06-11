require 'spec_helper'

RSpec.describe SidekiqUniquer::JobDigest do
  describe '.digest' do
    it 'returns the correct digest' do
      job = {
        'args' => [1, 2, 3],
        'class' => 'JobClass',
        'queue' => 'default'
      }

      expect(described_class.digest(job)).to eq('174b0d0b0e81112ff835301fad4e4ef6')
    end
  end
end