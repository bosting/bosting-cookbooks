package 'ssmtp'

template '/usr/local/etc/ssmtp/ssmtp.conf' do
  source 'ssmtp.conf.erb'
end

template '/etc/mail/mailer.conf' do
  source 'mailer.conf.erb'
end
