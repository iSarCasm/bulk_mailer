RSpec.describe BulkMailer::MailMessage do
  describe '.new' do
    let(:mail) { BulkMailer::Mail.new(unique_id: 'id', subject: 'subject', text: 'text') }
    let(:to) { 'user@mail.org' }
    let(:from) { 'support@web.com' }

    it 'sets mail' do
      mail_message = BulkMailer::MailMessage.new(mail: mail, to: to, from: from)
      expect(mail_message.mail).to eq mail
    end

    it 'sets to' do
      mail_message = BulkMailer::MailMessage.new(mail: mail, to: to, from: from)
      expect(mail_message.to).to eq to
    end

    context 'from is passed' do
      it 'sets from' do
        mail_message = BulkMailer::MailMessage.new(mail: mail, to: to, from: from)
        expect(mail_message.from).to eq from
      end
    end

    context 'from is not passed in params' do
      it 'sets default source' do
        allow(BulkMailer).to receive(:default_source).and_return('default@source.com')
        mail_message = BulkMailer::MailMessage.new(mail: mail, to: to)
        expect(mail_message.from).to eq 'default@source.com'
      end
    end
  end

  describe '#eql?' do
    describe 'equal when all params are equal' do
      it 'false' do
        mail_message1 = BulkMailer::MailMessage.new(mail: 'mail', to: 'to', from: 'from')
        mail_message2 = BulkMailer::MailMessage.new(mail: 'xxxx', to: 'to', from: 'from')

        expect(mail_message1).to_not eql mail_message2
      end

      it 'false' do
        mail_message1 = BulkMailer::MailMessage.new(mail: 'mail', to: 'to', from: 'from')
        mail_message2 = BulkMailer::MailMessage.new(mail: 'mail', to: 'xx', from: 'from')

        expect(mail_message1).to_not eql mail_message2
      end

      it 'false' do
        mail_message1 = BulkMailer::MailMessage.new(mail: 'mail', to: 'to', from: 'from')
        mail_message2 = BulkMailer::MailMessage.new(mail: 'mail', to: 'to', from: 'xxxx')

        expect(mail_message1).to_not eql mail_message2
      end

      it 'true' do
        mail_message1 = BulkMailer::MailMessage.new(mail: 'mail', to: 'to', from: 'from')
        mail_message2 = BulkMailer::MailMessage.new(mail: 'mail', to: 'to', from: 'from')

        expect(mail_message1).to eql mail_message2
      end
    end
  end

  describe '#subject' do
    it 'returns mails subject' do
      mail = build(:mail, subject: 'hello world')

      mail_message = build(:mail_message, mail: mail)

      expect(mail_message.subject).to eql 'hello world'
    end
  end

  describe '#text' do
    it 'returns mails text' do
      mail = build(:mail, text: 'mail text')

      mail_message = build(:mail_message, mail: mail)

      expect(mail_message.text).to eql 'mail text'
    end
  end
end