FactoryBot.define do
  factory :mail_message, class: 'BulkMailer::MailMessage' do
    mail { attributes_for(:mailbot_mail) }
    from nil
    to 'destination@mail.com'

    initialize_with do
      new(
        mail: attributes[:mail],
        from: attributes[:from],
        to: attributes[:to]
      )
    end
  end
end