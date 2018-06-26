RSpec.describe BulkMailer::BatchMessagesBuilder do
  it 'batches same mails together' do
    builder = BulkMailer::BatchMessagesBuilder.new
    recipient1 = 'recipient1'
    recipient2 = 'recipient2'
    mail = build :mail

    builder << build(:mail_message, mail: mail, to: recipient1, from: 'sarcasm')
    builder << build(:mail_message, mail: mail, to: recipient2, from: 'sarcasm')

    expect(builder.finalize)
      .to match_array([
        BulkMailer::MailBatchMessage.new(mail: mail, recipients: [recipient1, recipient2], from: 'sarcasm')
      ])
  end

  it 'batches mails of same content together' do
    builder = BulkMailer::BatchMessagesBuilder.new
    recipient1 = 'recipient1'
    recipient2 = 'recipient2'

    builder << build(:mail_message,
      mail: build(:mail, unique_id: :id, subject: 'subject 1', text: '123'),
      to: recipient1
    )
    builder << build(:mail_message,
      mail: build(:mail, unique_id: :id, subject: 'subject 1', text: '123'),
      to: recipient2
    )
    expect(builder.finalize).to match_array([
      BulkMailer::MailBatchMessage.new(
        mail: build(:mail, unique_id: :id, subject: 'subject 1', text: '123'),
        recipients: [recipient1, recipient2]
      )
    ])
  end

  it 'creates separate batches for different mails' do
    builder = BulkMailer::BatchMessagesBuilder.new
    recipient1 = 'recipient1'
    recipient2 = 'recipient2'
    mail1 = build(:mail, unique_id: :id, subject: 'subject 1', text: '123')
    mail2 = build(:mail, unique_id: :id, subject: 'subject 1', text: 'abc')

    builder << build(:mail_message, mail: mail1, to: recipient1)
    builder << build(:mail_message, mail: mail2, to: recipient2)

    expect(builder.finalize)
      .to match_array([
        BulkMailer::MailBatchMessage.new(mail: mail1, recipients: [recipient1]),
        BulkMailer::MailBatchMessage.new(mail: mail2, recipients: [recipient2])
      ])
  end

  it do
    builder = BulkMailer::BatchMessagesBuilder.new
    recipient1 = 'recipient1'
    recipient2 = 'recipient2'
    recipient3 = 'recipient3'
    mail1 = build(:mail, unique_id: :id, subject: 'subject 1', text: '123')
    mail2 = build(:mail, unique_id: :id, subject: 'subject 1', text: 'abc')

    builder << build(:mail_message, mail: mail1, to: recipient1)
    builder << build(:mail_message, mail: mail2, to: recipient2)
    builder << build(:mail_message, mail: mail2, to: recipient3)

    expect(builder.finalize)
      .to match_array([
        BulkMailer::MailBatchMessage.new(mail: mail1, recipients: [recipient1]),
        BulkMailer::MailBatchMessage.new(mail: mail2, recipients: [recipient2, recipient3])
      ])
  end
end