module BulkMailer
  class BatchMessagesBuilder
    attr_reader :unique_mails

    def initialize
      @unique_mails = {}
    end

    def <<(mail_message)
      if unique_mails[mail_message.mail]
        unique_mails[mail_message.mail] << mail_message.to
      else
        unique_mails[mail_message.mail] = MailBatchMessage.new(
          mail: mail_message.mail,
          recipients: [mail_message.to],
          from: mail_message.from
        )
      end
    end

    def finalize
      unique_mails.values
    end
  end
end