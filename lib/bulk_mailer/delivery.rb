module BulkMailer
  # Delivery object including recipients, their mail and email source
  class Delivery
    # Auto-generated MailBatchMessages from given recipients
    attr_reader :batches

    # Create new delivery
    #
    # @param [Array, #email] recipients array of recipient objects which have an #email property, and other properties required by mail's variables
    # @param [Block or BulkMailer::Mail] mail which mail to send to recipient
    # @param [String] from email's source, BulkMailer.default_source is used if no value is given
    #
    # == Example usage with mail:
    #
    #   mail = BulkMailer::Mail.new # any instance of BulkMailer::Mail
    #   BulkMailer::Delivery.new(recipients: UserRecipient.all, mail: mail, from: 'personal@google.com')
    # == Example usage with block:
    #
    #   BulkMailer::Delivery.new(recipients: UserRecipient.all, from: 'personal@google.com') do |recipient|
    #     if recipient.just_registered?
    #       welcome_mail # instance of BulkMailer::Mail
    #     else
    #       discount_mail # instance of BulkMailer::Mail
    #     end
    #   end
    #
    def initialize(recipients:, mail: nil, from: nil)
      raise ArgumentError, 'Either block or mail has to passed' unless block_given? || mail
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

    # Specifies delivery service: AWS or Mailgun
    #
    # @param [Symbol] api :mailgun, :aws
    # @param [Hash] config config overrides for this delivery
    #
    # == Example:
    #   delivery.deliver_with(:aws, batch_size: 10)
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
        when :mailgun then Mailgun::Client.new(config)
        when :aws     then AWS::Client.new(config)
        else raise ArgumentError, 'invalid client'
        end
      end
    end
  end
end