require 'bulk_mailer/version'

require 'attribute_accessors'
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

require 'bulk_mailer/aws/aws_client'

require 'bulk_mailer/mailgun/mailgun_client'
require 'bulk_mailer/mailgun/aws_template_to_mailgun_template'
require 'bulk_mailer/mailgun/errors/nil_mailgun_api_key'
require 'bulk_mailer/mailgun/errors/nil_mailgun_domain'

module BulkMailer
  def self.setup
    yield self
  end

  # Default emails 'from' source
  mattr_reader :default_source
  @@default_source = 'Example <example@example.com>'

  # Default Mailgun config
  mattr_reader :mailgun
  @@mailgun = {
    batch_size: 1000
  }

  # Default AWS SES config
  mattr_reader :aws
  @@aws = {
    encoding: 'UTF-8',
    aws_region: 'eu-west-1',
    batch_size: 1000
  }
end
