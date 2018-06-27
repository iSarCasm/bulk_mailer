RSpec.describe BulkMailer::Mailgun::ToMailgunTemplate do
  describe '.call' do
    it 'changes bulk variable style from {} to %recipient.%' do
      aws = <<~AWS
        Hello, {{name}}.
        We are glad that you bought {{product}}. Maybe, you will also be interested in https:\\website.com\{{relevant_link}}
      AWS
      mailgun = <<~MAILGUN
        Hello, %recipient.name%.
        We are glad that you bought %recipient.product%. Maybe, you will also be interested in https:\\website.com\%recipient.relevant_link%
      MAILGUN

      expect(BulkMailer::Mailgun::ToMailgunTemplate.call(aws)).to eq mailgun
    end
  end
end