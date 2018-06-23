RSpec.describe BulkMailer::Mail do
  describe '#recipient_variables' do
    describe 'returns all variables which are expeted per recipient for this email' do
      it 'captures all %recipient.SOMETHING%' do
        text = <<~TEXT
          Welcome here {{name}} also %,
          You can signup here: http://here.com?ref={{ref}}
          Get 100% income recipient gain for 10% effort.
        TEXT
        mail = BulkMailer::Mail.new(unique_id: :id, subject: '', text: text)

        expect(mail.recipient_variables).to eq %w[name ref]
      end
    end
  end

  describe '#open_in_browser' do
    let(:mail) { BulkMailer::Mail.new(unique_id: :id, subject: 'subject', text: 'text') }
    before { allow_any_instance_of(Launchy::Application::Browser).to receive(:open) }

    context 'in production ENV' do
      before { allow(ENV).to receive(:[]).with('RAILS_ENV').and_return('production') }

      it 'raises an error' do
        expect { mail.open_in_browser }.to raise_error(BulkMailer::NotAllowedInProduction)
      end
    end

    context 'in not-production ENV' do
      before { allow(SecureRandom).to receive(:uuid).and_return('tmp') }
      let(:file) { '/tmp/email_previews/tmp.html' }

      it 'creates a tmp file' do
        FileUtils.rm(file) if File.exist?(file)

        mail.open_in_browser

        expect(File.exist?(file)).to eq true
      end

      it 'opens tmp file in browser' do
        expect(Launchy).to receive(:open).with(file)

        mail.open_in_browser
      end
    end
  end
end