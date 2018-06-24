RSpec.describe BulkMailer::MailBatchMessage do
  subject { BulkMailer::MailBatchMessage }

  describe '==' do
    describe 'compares by mail, recipients and from' do
      it do
        batch_1 = subject.new mail: 'mail', recipients: [], from: 'me@google.com'
        batch_2 = subject.new mail: 'mail', recipients: [], from: 'me@google.com'

        expect(batch_1).to eq batch_2
      end

      it do
        batch_1 = subject.new mail: 'mail1', recipients: [], from: 'me@google.com'
        batch_2 = subject.new mail: 'mail2', recipients: [], from: 'me@google.com'

        expect(batch_1).not_to eq batch_2
      end

      it do
        batch_1 = subject.new mail: 'mail', recipients: [1, 2, 3], from: 'me@google.com'
        batch_2 = subject.new mail: 'mail', recipients: [3, 2, 1], from: 'me@google.com'

        expect(batch_1).to eq batch_2
      end

      it do
        batch_1 = subject.new mail: 'mail', recipients: [1, 2, 3], from: 'me@google.com'
        batch_2 = subject.new mail: 'mail', recipients: [3, 2], from: 'me@google.com'

        expect(batch_1).not_to eq batch_2
      end
    end
  end

  describe '#recipient_variables' do
    it 'returns a hash of all expected by current mail variables' do
      mail = double('mail', recipient_variables: %w[name gender cash])
      recipient = double('mail', name: 'Sasha', gender: 'f', cash: 100_000)
      batch = build :mail_batch_message, mail: mail, recipients: [recipient]

      expect(batch.recipient_variables(recipient)).to eq(
        'name' => 'Sasha',
        'gender' => 'f',
        'cash' => 100_000
      )
    end
  end
end