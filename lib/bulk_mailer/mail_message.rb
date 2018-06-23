module BulkMailer
  class MailMessage
    attr_reader :mail, :to, :from

    def initialize(mail:, to: nil, from: nil)
      @mail = mail
      @to = to
      @from = from || BulkMailer.default_source
    end

    def subject
      mail.subject
    end

    def text
      mail.text
    end

    def eql?(other)
      mail == other.mail && to == other.to && from == other.from
    end
    alias == eql?
  end
end