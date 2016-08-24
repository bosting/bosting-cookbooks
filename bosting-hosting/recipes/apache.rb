apache_version_short = node['bosting-hosting']['apache_version_short']
php_version_short = node['bosting-hosting']['php_version_short']

link '/usr/local/etc/apache' do
  to "/usr/local/etc/apache#{apache_version_short}"
end

apache_prefix = "/usr/local/etc/apache#{apache_version_short}"

%w(servers shorter).each do |dir|
  directory "#{apache_prefix}/#{dir}" do
    mode 0750
  end
end

%w(files_match_ht.conf log_config.conf).each do |file|
  cookbook_file "#{apache_prefix}/shorter/#{file}" do
    source "apache#{apache_version_short}/shorter/#{file}"
  end
end

template "#{apache_prefix}/shorter/mime_module.conf" do
  source 'mime_module.conf.erb'
  variables(apache_version_short: apache_version_short)
end

template "#{apache_prefix}/shorter/mod_mime_php.conf" do
  source 'mod_mime_php.conf.erb'
  variables(php_version: php_version_short[0])
end

template "#{apache_prefix}/shorter/dso.conf" do
  source "apache#{apache_version_short}/dso.conf.erb"
  variables(php_version: php_version_short[0])
end

template "#{apache_prefix}/shorter/mod_rpaf.conf" do
  source 'mod_rpaf.conf.erb'
  variables(ip: node['bosting-hosting']['ip'])
end

directory '/var/log/httpd' do
  owner 'www'
  group 'www'
  mode 0750
end
