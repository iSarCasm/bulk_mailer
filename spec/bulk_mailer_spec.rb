RSpec.describe BulkMailer do
  describe '.setup' do
    it 'yields self' do
      BulkMailer.setup do |config|
        expect(config).to eq BulkMailer
      end
    end
  end
end
