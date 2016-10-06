append_if_no_line 'disable sendmail' do
  path '/etc/rc.conf'
  line 'sendmail_enable="NONE"'
end

service 'sendmail' do
  action :stop
end

file '/etc/periodic.conf'

%w(
  daily_clean_hoststat_enable="NO"
  daily_status_mail_rejects_enable="NO"
  daily_status_include_submit_mailq="NO"
  daily_submit_queuerun="NO"
).each do |add_line|
  append_if_no_line "Add '#{add_line}' to /etc/periodic.conf" do
    path '/etc/periodic.conf'
    line add_line
  end
end
