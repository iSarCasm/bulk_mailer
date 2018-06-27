RSpec.describe BulkMailer::Delivery do
  let(:recipients) { [double('recipient', email: Faker::Internet.email)] }

  describe '.new' do
    context 'mail given' do
      let(:mail) { build :mail }

      it 'assigns single batch for this mail' do
        delivery = BulkMailer::Delivery.new(recipients: recipients, mail: mail)

        expect(delivery.batches).to eq([BulkMailer::MailBatchMessage.new(mail: mail, recipients: recipients)])
      end
    end

    context 'block given' do
      let(:recipients) { [double('recipient', email: Faker::Internet.email)] * 6 }

      it 'creates multiple mail batches' do
        mails = [
          build(:mail, unique_id: 'id', subject: 'subject', text: 'text'),
          build(:mail, unique_id: 'id2', subject: 'subject2', text: 'text2'),
          build(:mail, unique_id: 'id2', subject: 'subject2', text: 'text2'),
          build(:mail, unique_id: 'id3', subject: 'subject3', text: 'text3'),
          build(:mail, unique_id: 'id3', subject: 'subject3', text: 'text3')
        ]
        delivery = BulkMailer::Delivery.new(recipients: recipients) do
          mails.pop
        end

        expect(delivery.batches.size).to eq 3
      end
    end

    context 'no block no mail' do
      it 'raises error' do
        expect { BulkMailer::Delivery.new(recipients: recipients) }.to raise_error(ArgumentError)
      end
    end
  end

  describe '#deliver_with' do
    describe 'it calls #deliver_batches on correct client' do
      context 'given class' do
        it 'calls on given class' do
          new_class = Class.new do
            def initialize(arg); end
            def deliver_batches(arg); end
          end

          expect_any_instance_of(new_class).to receive(:deliver_batches)

          BulkMailer::Delivery.new(recipients: recipients) {}.deliver_with(new_class)
        end
      end

      context 'given symbol' do
        before do
          config = BulkMailer.mailgun
          allow(BulkMailer).to receive(:mailgun)
            .and_return(config.merge(api_key: 'API KEY', domain: 'DOMAIN'))
        end

        it 'mailgun' do
          expect_any_instance_of(BulkMailer::Mailgun::Client).to receive(:deliver_batches)
          BulkMailer::Delivery.new(recipients: recipients) {}.deliver_with(:mailgun)
        end

        it 'aws' do
          expect_any_instance_of(BulkMailer::AWS::Client).to receive(:deliver_batches)
          BulkMailer::Delivery.new(recipients: recipients) {}.deliver_with(:aws)
        end

        it 'raises error' do
          expect { BulkMailer::Delivery.new(recipients: recipients) {}.deliver_with(:abracadbra) }
            .to raise_error(ArgumentError, 'invalid client')
        end
      end
    end
  end
end