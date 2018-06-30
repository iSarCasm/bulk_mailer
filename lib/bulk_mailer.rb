require 'bulk_mailer/version'

require 'active_support'
require 'securerandom'
require 'launchy'
require 'aws-sdk'
require 'mailgun-ruby'

require 'bulk_mailer/errors/not_allowed_in_production'

require 'bulk_mailer/mail'
require 'bulk_mailer/mail_message'
require 'bulk_mailer/mail_batch_message'
require 'bulk_mailer/batch_messages_builder'
require 'bulk_mailer/delivery'

require 'bulk_mailer/aws/client'

require 'bulk_mailer/mailgun/client'
require 'bulk_mailer/mailgun/to_mailgun_template'
require 'bulk_mailer/mailgun/errors/nil_mailgun_api_key'
require 'bulk_mailer/mailgun/errors/nil_mailgun_domain'

# Designed to send bulk mails without getting into API details of each email gateway
module BulkMailer
  # Use to define settings for gateways
  # == Example usage:
  #
  #   BulkMailer.setup do |config|
  #     config.default_source = 'Your Name <your_email@domain.org>'
  #
  #     config.mailgun = {
  #       batch_size: 500,
  #       api_key: ENV['MAILGUN_API_KEY'],
  #       domain: ENV['MAILGUN_DOMAIN']
  #     }
  #
  #     config.aws = {
  #       encoding: 'UTF-8',
  #       aws_region: 'eu-central-1',
  #       batch_size: 250
  #     }
  #   end
  def self.setup
    yield self
  end

  # Default emails 'from' source
  mattr_accessor :default_source
  @@default_source = 'Example <example@example.com>'

  mattr_accessor :mailgun
  @@mailgun = {
    # number of emails sent in single HTTP request to Mailgun
    # (refer to Mailgun official documentation for max. allowed value)
    batch_size: 1000,
    # Mailgun's secret API KEY
    api_key: nil,
    # Mailgun's domain
    domain: nil
  }

  # Default AWS SES config
  mattr_accessor :aws
  @@aws = {
    # email encoding
    encoding: 'UTF-8',
    # Your AWS region
    aws_region: 'eu-west-1',
    # number of emails sent in single HTTP request to Mailgun
    # (refer to AWS SES official documentation for max. allowed value)
    batch_size: 1000
  }
end
