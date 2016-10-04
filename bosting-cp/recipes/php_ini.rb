if node['bosting-hosting'].nil?
  apache_version_short = '24'
  php_version_short = 56
else
  apache_version_short = node['bosting-hosting']['apache_version_short']
  php_version_short = node['bosting-hosting']['php_version_short'].to_i
end

service "apache#{apache_version_short}" do
  supports restart: true, reload: true, status: true
  action :nothing
end

php_settings = [
  %w(short_open_tag On),
  %w(expose_php Off),
  %w(max_execution_time 600),
  %w(memory_limit 512M),
  ['error_reporting', 'E_ALL & ~E_DEPRECATED & ~E_NOTICE'],
  %w(post_max_size 256M),
  ['include_path', '".:/usr/local/share/pear"'],
  %w(upload_max_filesize 256M),
  %w(allow_url_include On),
  %w(mysql.allow_persistent Off),
  %w(mysqli.allow_persistent Off)
]

if php_version_short < 54
  php_settings.concat([%w(register_globals On)])
end

execute 'cp /usr/local/etc/php.ini-production /usr/local/etc/php.ini' do
  creates '/usr/local/etc/php.ini'
  notifies :reload, "service[apache#{apache_version_short}]"
end

php_settings.each do |setting, value|
  replace_or_add "set #{setting} to #{value} in php.ini"do
    path '/usr/local/etc/php.ini'
    pattern setting
    line "#{setting} = #{value}"
    notifies :reload, "service[apache#{apache_version_short}]"
  end
end

# TODO
# date.timezone = "Europe/Moscow"
