FactoryBot.define do
  factory :mail_batch_message, class: 'BulkMailer::MailBatchMessage' do
    mail { attributes_for(:mailbot_mail) }
    recipients []
    from nil

    initialize_with do
      new(
        mail: attributes[:mail],
        recipients: attributes[:recipients],
        from: attributes[:from]
      )
    end
  end
end