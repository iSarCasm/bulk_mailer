module BulkMailer
  module AwsTemplateToMailgunTemplate
    def self.call(aws)
      aws.gsub(/{{(.+?)}}/) { |x| "%recipient.#{x[2..-3]}%" }
    end
  end
end