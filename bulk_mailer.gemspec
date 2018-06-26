
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "bulk_mailer/version"

Gem::Specification.new do |spec|
  spec.name          = "bulk_mailer"
  spec.version       = BulkMailer::VERSION
  spec.authors       = ["SarCasm"]
  spec.email         = ["sarcasm008@gmail.com"]

  spec.summary       = %q{Send Bulk/Batch emails easily with AWS, Mailgun}
  spec.description   = %q{Send Bulk/Batch emails easily with AWS, Mailgun}
  spec.homepage      = "https://github.com/iSarCasm/bulk_mailer"
  spec.license       = "MIT"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency 'launchy'
  spec.add_dependency 'aws-sdk', '~> 3'
  spec.add_dependency 'mailgun-ruby', '~> 1.1.8'
  spec.add_dependency 'activesupport', '~> 5'
  spec.add_development_dependency "bundler", "~> 1.16"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "guard-rspec"
  spec.add_development_dependency 'rubocop'
  spec.add_development_dependency 'guard-rubocop'
  spec.add_development_dependency 'factory_bot'
  spec.add_development_dependency 'webmock'
  spec.add_development_dependency 'faker'
  spec.add_development_dependency 'simplecov'
end
