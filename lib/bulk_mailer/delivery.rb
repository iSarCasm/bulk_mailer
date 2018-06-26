module BulkMailer
  class Delivery
    attr_reader :batches

    def initialize(recipients:, mail: nil, from: nil)
      raise ArgumentError, 'Either block or mails have to passed' unless block_given? || mail
      @batches = recipients.each_with_object(BatchMessagesBuilder.new) do |recipient, builder|
        recipient_mail = mail || yield(recipient)
        next unless recipient_mail
        builder << MailMessage.new(
          mail: recipient_mail,
          from: from,
          to: recipient
        )
      end.finalize
    end

    def deliver_with(api, config = {})
      client = get_client_for api, config
      client.deliver_batches(batches) do |mail_batch_message|
        mail_batch_message.recipients.each do |recipient|
          yield(recipient, mail_batch_message.mail) if block_given?
        end
      end
    end

    private

    def get_client_for(api, config)
      if api.is_a?(Class)
        api.new(config)
      else
        case api.to_sym
        when :mailgun then MailgunClient.new(config)
        when :aws     then AwsClient.new(config)
        else raise ArgumentError, 'invalid client'
        end
      end
    end
  end
end