directory '/var/ports'

make_conf_path = '/etc/make.conf'

file make_conf_path do
  mode 0644
end

replace_or_add 'add WITHOUT_X11=true to make.conf' do
  path make_conf_path
  pattern '^WITHOUT_X11=.*'
  line 'WITHOUT_X11=true'
end

append_if_no_line 'add OPTIONS_UNSET+=X11 to make.conf' do
  path make_conf_path
  line 'OPTIONS_UNSET+=X11'
end

replace_or_add 'add WRKDIRPREFIX=/var/ports to make.conf' do
  path make_conf_path
  pattern '^WRKDIRPREFIX=.*'
  line 'WRKDIRPREFIX=/var/ports'
end

%w(DISTDIR PACKAGES INDEXDIR).each do |line|
  delete_lines "remove #{line} from #{make_conf_path}" do
    path make_conf_path
    pattern "^#{line}="
  end
end
