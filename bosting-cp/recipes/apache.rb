if node['platform'] == 'freebsd'
  package 'apache24'
  package 'php56'
  package 'mod_php56'
  package 'ap24-mod_rpaf2'

  service 'apache24' do
    supports restart: true, reload: true, status: true
    action :nothing
  end

  httpd_path = '/usr/local/etc/apache24'
  httpd_conf = "#{httpd_path}/httpd.conf"

  replace_or_add 'set apache to listen on 127.0.0.1' do
    path httpd_conf
    pattern '^Listen 80'
    line 'Listen 127.0.0.1:80'
    notifies :reload, 'service[apache24]'
  end

  replace_or_add 'set ServerName' do
    path httpd_conf
    pattern '^#ServerName'
    line "ServerName #{node['bosting-cp']['fqdn']}"
    notifies :reload, 'service[apache24]'
  end

  replace_or_add 'set DirectoryIndex' do
    path httpd_conf
    pattern "^\tDirectoryIndex"
    line "\tDirectoryIndex index.php index.html"
    notifies :reload, 'service[apache24]'
  end

  replace_or_add 'enable mod_rpaf' do
    path httpd_conf
    pattern "^#LoadModule rpaf_module        libexec/apache24/mod_rpaf.so"
    line "LoadModule rpaf_module        libexec/apache24/mod_rpaf.so"
    notifies :reload, 'service[apache24]'
  end

  template "#{httpd_path}/Includes/sites.conf" do
    source 'apache-sites.conf.erb'
    variables(www_path: '/usr/local/www')
    notifies :reload, 'service[apache24]'
  end

  cookbook_file "#{httpd_path}/Includes/php.conf" do
    source 'apache-php.conf'
    notifies :reload, 'service[apache24]'
  end

  service 'apache24' do
    action [:enable, :start]
  end
end
