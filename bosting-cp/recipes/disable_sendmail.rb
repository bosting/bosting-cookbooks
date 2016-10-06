append_if_no_line 'disable sendmail' do
  path '/etc/rc.conf'
  line 'sendmail_enable="NONE"'
end

service 'sendmail' do
  action :stop
end
