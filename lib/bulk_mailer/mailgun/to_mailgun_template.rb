module BulkMailer
  module Mailgun
    module ToMailgunTemplate
      def self.call(aws)
        aws.gsub(/{{(.+?)}}/) { |x| "%recipient.#{x[2..-3]}%" }
      end
    end
  end
end