RSpec.describe BulkMailer::AWS::Client do
  describe '.new' do
    context 'given config' do
      let(:config) { { aws_region: 'eu-west-2', encoding: 'encoding', batch_size: 4 } }

      it 'merges aws region' do
        client = BulkMailer::AWS::Client.new(config)
        expect(client.aws_region).to eq 'eu-west-2'
      end

      it 'merges encoding' do
        client = BulkMailer::AWS::Client.new(config)
        expect(client.encoding).to eq 'encoding'
      end

      it 'merges batch size' do
        client = BulkMailer::AWS::Client.new(config)
        expect(client.batch_size).to eq 4
      end
    end

    context 'no config' do
      before do
        allow(BulkMailer).to receive(:aws).and_return(
          aws_region: 'eu-west-1',
          encoding: 'default encoding'
        )
      end

      it 'uses default aws region' do
        client = BulkMailer::AWS::Client.new
        expect(client.aws_region).to eq 'eu-west-1'
      end

      it 'uses default encoding' do
        client = BulkMailer::AWS::Client.new
        expect(client.encoding).to eq 'default encoding'
      end
    end
  end

  describe '#deliver_batches' do
    before do
      stub_request(:post, 'https://email.eu-west-1.amazonaws.com/').
        to_return(status: 200, body: "", headers: {})
    end

    let(:client) { BulkMailer::AWS::Client.new }
    let(:recipients) do
      [
        double(:user_recipient, email: Faker::Internet.email),
        double(:user_recipient, email: Faker::Internet.email),
        double(:user_recipient, email: Faker::Internet.email)
      ]
    end
    let(:mail) { BulkMailer::Mail.new(unique_id: 'id', subject: 'subject', text: 'text') }
    let(:batch) do
      BulkMailer::MailBatchMessage.new(
        mail: mail,
        recipients: recipients
      )
    end

    it 'checks for an AWS template for each batch mail' do
      allow(client.client).to receive(:send_bulk_templated_email).and_return(
        double('response', status: 'Success')
      )

      expect(client.client).to receive(:get_template).with({template_name: 'id'}).
        and_return(double('template response', template:
          double('template', subject_part: 'subject', html_part: 'text')
        )
      )

      client.deliver_batches([batch])
    end

    context 'AWS template does not exist yet' do
      before do
        allow(client.client).to receive(:get_template)
          .and_raise(Aws::SES::Errors::TemplateDoesNotExist.new('',''))
      end

      it 'creates new AWS template' do
        allow(client.client).to receive(:send_bulk_templated_email).and_return(
          double('response', status: 'Success')
        )

        expect(client.client).to receive(:create_template).with({
          template: {
            template_name: 'id',
            subject_part: 'subject',
            html_part: 'text'
          }
        })

        client.deliver_batches([batch])
      end
    end

    context 'AWS template content mismatched' do
      before do
        allow(client.client).to receive(:get_template)
          .and_return(double('template response', template: double(
            'template',
            subject_part: 'subject',
            html_part: 'different text'
          )))
      end

      it  'updates template with new content' do
        allow(client.client).to receive(:send_bulk_templated_email).and_return(
          double('response', status: 'Success')
        )

        expect(client.client).to receive(:update_template).with(
          template: {
            template_name: 'id',
            subject_part: 'subject',
            html_part: 'text'
          }
        )

        client.deliver_batches([batch])
      end
    end

    context 'AWS template setup correctly' do
      before do
        allow(client.client).to receive(:get_template)
          .and_return(double('template response', template: double(
            'template',
            subject_part: 'subject',
            html_part: 'text'
          )))
      end

      it 'send bulk message to AWS' do
        user_recipients = [
          double(:user_recipient, email: 'amanda@mail.ru', ref_token: 'amanda'),
          double(:user_recipient, email: 'sam@mail.ru', ref_token: 'sam'),
          double(:user_recipient, email: 'travis@mail.ru', ref_token: 'travis')
        ]
        mail = BulkMailer::Mail.new(
          unique_id: 'welcome',
          subject: 'hello world',
          text: 'hello {{ref_token}}'
        )
        batch = BulkMailer::MailBatchMessage.new(
          mail: mail,
          recipients: user_recipients,
          from: 'admin@mysite.com'
        )

        expect(client.client).to receive(:send_bulk_templated_email).with(
          source: 'admin@mysite.com',
          template: 'welcome',
          default_template_data: { ref_token: 'amanda' }.to_json,
          destinations: [
            {
              destination: { to_addresses: ['amanda@mail.ru'] },
              replacement_template_data: { ref_token: 'amanda' }.to_json
            },
            {
              destination: { to_addresses: ['sam@mail.ru'] },
              replacement_template_data: { ref_token: 'sam' }.to_json
            },
            {
              destination: { to_addresses: ['travis@mail.ru'] },
              replacement_template_data: { ref_token: 'travis' }.to_json
            }
          ]
        ).and_return(double('response', status: 'Success'))

        client.deliver_batches([batch])
      end
    end
  end
end