module BulkMailer
  class Mail
    attr_reader :unique_id, :subject, :text, :recipient_variables

    def initialize(unique_id:, subject:, text:)
      @unique_id  = unique_id
      @subject    = subject
      @text       = text
      @recipient_variables = text.scan(/{{(.*?)}}/).map(&:first)
    end

    def open_in_browser
      raise NotAllowedInProduction if ENV['RAILS_ENV'] == 'production'

      tmp_file_path = "/tmp/email_previews/#{SecureRandom.uuid}.html"
      dirname = File.dirname(tmp_file_path)
      FileUtils.mkdir_p(dirname) unless File.directory? File.dirname(tmp_file_path)
      File.open(tmp_file_path, 'wb') { |f| f.write text }

      Launchy.open(tmp_file_path)
    end

    def hash
      unique_id.hash ^ subject.hash ^ text.hash
    end

    def ==(other)
      unique_id == other.unique_id && subject == other.subject && text == other.text
    end
    alias eql? ==
  end
end