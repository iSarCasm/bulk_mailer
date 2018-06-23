require 'bulk_mailer/version'

require 'bulk_mailer/errors/not_allowed_in_production'

require 'bulk_mailer/mail'
require 'attribute_accessors'

require 'securerandom'
require 'launchy'

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
    batch_size: 1000
  }
end
