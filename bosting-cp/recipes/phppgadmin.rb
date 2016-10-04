if node['platform'] == 'freebsd'
  freebsd_port 'phppgadmin'

  replace_or_add 'turn off extra_login_security' do
    path '/usr/local/www/phpPgAdmin/conf/config.inc.php'
    pattern '\$conf\[\'extra_login_security\'\]'
    line "\t$conf['extra_login_security'] = false;"
  end
end
