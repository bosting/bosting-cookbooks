case node['platform']
when 'freebsd'
  package 'phpMyAdmin-php74' do
    notifies :reload, 'service[apache24]'
  end
when 'debian'
  package 'phpMyAdmin' do
    notifies :reload, 'service[apache]'
  end
end

dest_path = '/usr/local/www/phpMyAdmin/config.inc.php'
blowfish_secret = generate_blowfish_secret
template dest_path do
  sensitive true
  source 'phpmyadmin.conf.erb'
  variables blowfish_secret: blowfish_secret
  not_if { ::File.foreach(dest_path).grep(/blowfish_secret/).any? }
end
