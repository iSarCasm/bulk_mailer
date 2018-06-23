FactoryBot.define do
  factory :mail, class: 'BulkMailer::Mail' do
    unique_id 'id'
    subject 'subject'
    text 'text'

    initialize_with do
      new(
        unique_id: attributes[:unique_id],
        subject: attributes[:subject],
        text: attributes[:text]
      )
    end
  end
end