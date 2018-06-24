RSpec.describe BulkMailer::MailgunClient do
  before do
    config = BulkMailer.mailgun
    allow(BulkMailer).to receive(:mailgun)
      .and_return(config.merge(api_key: 'API KEY', domain: 'DOMAIN'))
  end

  describe '.new' do
    context 'given config' do
      let(:config) { {api_key: 'api key', domain: 'domain', batch_size: 10} }

      it 'merges api key' do
        expect(Mailgun::Client).to receive(:new).with('api key')
        client = BulkMailer::MailgunClient.new(config)
      end

      it 'merges domain' do
        client = BulkMailer::MailgunClient.new(config)
        expect(client.domain).to eq 'domain'
      end

      it 'merges batch size' do
        client = BulkMailer::MailgunClient.new(config)
        expect(client.batch_size).to eq 10
      end
    end

    context 'no config' do
      before do
        allow(BulkMailer).to receive(:mailgun).and_return({
          api_key: 'default api key',
          domain: 'default domain',
          batch_size: 20
        })
      end

      it 'uses default api key' do
        expect(Mailgun::Client).to receive(:new).with('default api key')
        client = BulkMailer::MailgunClient.new
      end

      it 'uses default domain' do
        client = BulkMailer::MailgunClient.new
        expect(client.domain).to eq 'default domain'
      end

      it 'uses default batch size' do
        client = BulkMailer::MailgunClient.new
        expect(client.batch_size).to eq 20
      end
    end
  end

  describe '#deliver_batches' do
    before do
      stub_request(:post, "https://api.mailgun.net/v3/DOMAIN/messages").
        to_return(status: 200, body: {id: '123'}.to_json, headers: {})
    end

    context 'batch size is 2' do
      let(:client) { BulkMailer::MailgunClient.new batch_size: 2 }

      context 'given 2 batch mails 3 recipients each' do
        it 'makes 4 requests to mailgun and changes mail text format' do
          mail1 = BulkMailer::Mail.new(unique_id: '1', subject: '1', text: '{{ref_token}}')
          mail2 = BulkMailer::Mail.new(unique_id: '2', subject: '2', text: '{{ref_token}}')
          recipients1 = [double(:user_recipient, email: Faker::Internet.email, ref_token: SecureRandom.uuid)] * 3
          recipients2 = [double(:user_recipient, email: Faker::Internet.email, ref_token: SecureRandom.uuid)] * 3
          batch1 = BulkMailer::MailBatchMessage.new(
            mail: mail1,
            recipients: recipients1
          )
          batch2 = BulkMailer::MailBatchMessage.new(
            mail: mail2,
            recipients: recipients2
          )

          client.deliver_batches([batch1, batch2])

          request1 = batch_request(
            [recipients1[0], recipients1[1]],
            mail1,
            html: '%recipient.ref_token%',
            variables: ['ref_token']
          )
          request2 = batch_request(
            [recipients1[2]],
            mail1,
            html: '%recipient.ref_token%',
            variables: ['ref_token']
          )
          request3 = batch_request(
            [recipients2[0], recipients2[1]],
            mail2,
            html: '%recipient.ref_token%',
            variables: ['ref_token']
          )
          request4 = batch_request(
            [recipients2[2]],
            mail2,
            html: '%recipient.ref_token%',
            variables: ['ref_token']
          )
          expect(request1).to have_been_made.once
          expect(request2).to have_been_made.once
          expect(request3).to have_been_made.once
          expect(request4).to have_been_made.once
        end
      end
    end

    it 'yields a block on each batch mail' do
      client = BulkMailer::MailgunClient.new
      batch = BulkMailer::MailBatchMessage.new(
        mail: BulkMailer::Mail.new(unique_id: '1', subject: '1', text: 'text'),
        recipients: [double(:user_recipient, email: Faker::Internet.email)] * 3
      )

      expect(batch).to receive(:to_s)

      client.deliver_batches([batch]) { |b| b.to_s }
    end
  end

  def batch_request(recipients, mail, from: nil, subject: nil, html: nil, variables: [])
    recipient = recipients.first

    from    = from || 'Example <example@example.com>'
    to      = recipients.map { |r| "'' <#{r.email}>" }
    subject = subject || mail.subject
    html    = html || mail.text
    variables = recipients.each_with_object({}) do |r, all_vars|
      all_vars[r.email] = variables.each_with_object({}) do |var, vars|
        vars[var.to_s] = r.send(var)
      end
    end.to_json

    a_request(:post, "https://api.mailgun.net/v3/DOMAIN/messages").with(
      body: {
        from: [from],
        to: to,
        subject: [subject],
        html: [html],
        'recipient-variables' => variables
      }
    )
  end
end