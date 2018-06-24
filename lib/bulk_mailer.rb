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

require 'bulk_mailer/aws/aws_client'

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
