module BulkMailer
  class MailBatchMessage
    attr_reader :mail, :recipients, :from

    def initialize(mail:, recipients: [], from: nil)
      @mail = mail
      @recipients = recipients
      @from = from || BulkMailer.default_source
    end

    def unique_id
      mail.unique_id
    end

    def subject
      mail.subject
    end

    def text
      mail.text
    end

    def add_recipient(recipient)
      @recipients << recipient
    end
    alias << add_recipient

    def recipient_variables(recipient)
      mail.recipient_variables.each_with_object({}) do |variable, recipient_variables|
        recipient_variables[variable] = recipient.send(variable)
      end
    end

    def ==(other)
      mail == other.mail && recipients.sort == other.recipients.sort && from == other.from
    end
  end
end