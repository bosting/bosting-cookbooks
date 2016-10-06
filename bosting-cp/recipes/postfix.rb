package 'postfix'

template '/etc/mail/mailer.conf' do
  source 'mailer.conf.erb'
end

service 'postfix' do
  supports restart: true, reload: true, status: true
  action [:enable, :start]
end
