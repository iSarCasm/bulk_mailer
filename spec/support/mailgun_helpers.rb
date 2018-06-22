module MailbotHelpers
  def set_mailbot_mailgun_config(api_key: 'abcdefg', domain: 'abcdefg')
    mailgun_config = {
      api_key: api_key,
      domain: domain
    }
    default_config = Mailbot.mailgun
    allow(Mailbot).to receive(:mailgun).and_return(default_config.merge(mailgun_config))
  end
end