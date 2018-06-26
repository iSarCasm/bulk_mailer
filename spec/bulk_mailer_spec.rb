RSpec.describe BulkMailer do
  describe '.setup' do
    it 'yields self' do
      BulkMailer.setup do |config|
        expect(config).to eq BulkMailer
      end
    end

    it 'can update default_source' do
      expect do
        BulkMailer.setup do |c|
          c.default_source = 'Hello world'
        end
      end.to change { BulkMailer.default_source }.to('Hello world')
    end
  end
end
