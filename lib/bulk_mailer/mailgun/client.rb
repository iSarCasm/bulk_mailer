module BulkMailer
  module Mailgun
    class Client
      attr_reader :client, :domain, :batch_size, :api_key

      def initialize(config = {})
        config = BulkMailer.mailgun.merge(config)
        @api_key = config[:api_key]
        @client = ::Mailgun::Client.new api_key
        @domain = config[:domain]
        @batch_size = config[:batch_size]

        # Raise these exceptions manually here because mailgun-ruby exceptions are not descriptive
        raise NilMailgunApiKey, 'Set mailgun API key in BulkMailer\'s initializer' unless api_key
        raise NilMailgunDomain, 'Set mailgun domain in BulkMailer\'s initializer'  unless domain
      end

      def deliver_batches(batch_mails)
        batch_mails.each_with_object([]) do |batch_mail, responses|
          batch_mail.recipients.each_slice(batch_size) do |recipients|
            response = create_batch_message(batch_mail, recipients).finalize
            responses << response
            if successful_response? response
              yield(batch_mail) if block_given?
            end
          end
        end
      end

      private

      def successful_response?(response)
        response.is_a? Hash
      end

      def create_batch_message(batch_mail, recipients)
        batch = ::Mailgun::BatchMessage.new client, domain
        batch.from batch_mail.from
        batch.subject batch_mail.subject
        batch.body_html ToMailgunTemplate.call(batch_mail.text)
        recipients.each do |recipient|
          batch.add_recipient(:to, recipient.email, batch_mail.recipient_variables(recipient))
        end
        batch
      end
    end
  end
end