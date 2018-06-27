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

# Designed to send bulk mails
module BulkMailer
  def self.setup
    yield self
  end

  # Default emails 'from' source
  mattr_accessor :default_source
  @@default_source = 'Example <example@example.com>'

  # Default Mailgun config
  mattr_accessor :mailgun
  @@mailgun = {
    batch_size: 1000
  }

  # Default AWS SES config
  mattr_accessor :aws
  @@aws = {
    encoding: 'UTF-8',
    aws_region: 'eu-west-1',
    batch_size: 1000
  }
end
