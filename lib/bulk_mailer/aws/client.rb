module BulkMailer
  module AWS
    class Client
      attr_reader :aws_region, :encoding, :batch_size, :client

      def initialize(config = {})
        config = BulkMailer.aws.merge(config)
        @aws_region = config[:aws_region]
        @encoding   = config[:encoding]
        @batch_size = config[:batch_size]
        @client = Aws::SES::Client.new(region: aws_region)
      end

      def deliver_batches(batch_mails)
        batch_mails.each_with_object([]) do |batch_mail, responses|
          setup_template(batch_mail.mail)
          response = send_bulk_message(batch_mail)
          responses << response
          if successful_response? response
            yield(batch_mail) if block_given?
          end
        end
      end

      private

      def setup_template(mail)
        template = client.get_template(template_name: mail.unique_id).template
        if template.subject_part != mail.subject || template.html_part != mail.text
          update_template mail
        end
      rescue Aws::SES::Errors::TemplateDoesNotExist
        create_template mail
      end

      def create_template(mail)
        client.create_template(
          template: {
            template_name: mail.unique_id,
            subject_part: mail.subject,
            html_part: mail.text
          }
        )
      end

      def update_template(mail)
        client.update_template(
          template: {
            template_name: mail.unique_id,
            subject_part: mail.subject,
            html_part: mail.text
          }
        )
      end

      def successful_response?(response)
        response.status == 'Success'
      end

      def send_bulk_message(batch_mail)
        client.send_bulk_templated_email aws_request(batch_mail)
      end

      def aws_request(batch_mail)
        {
          source: batch_mail.from,
          template: batch_mail.mail.unique_id.to_s,
          default_template_data: batch_mail.recipient_variables(batch_mail.recipients[0]).to_json,
          destinations: destinations(batch_mail)
        }
      end

      def destinations(batch_mail)
        batch_mail.recipients.map do |recipient|
          {
            destination: {
              to_addresses: [recipient.email]
            },
            replacement_template_data: batch_mail.recipient_variables(recipient).to_json
          }
        end
      end
    end
  end
end