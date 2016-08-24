default['ruby_build']['git_ref'] = 'v20160426'
default['rbenv']['git_ref'] = 'v1.0.0'
default['rbenv']['rubies'] = ['2.2.5']
default['rbenv']['gems'] = { '2.2.5' => [{ 'name' => 'bundler' }] }
default['bosting-cp']['mysql_connection_info'] = {
    username: 'root',
    password: node['bosting-cp']['mysql_root_password'],
    socket: '/tmp/mysql.sock'
}
default['bosting-cp']['nginx_conf_base'] = case node['platform']
                                             when 'freebsd'
                                               '/usr/local/etc/nginx'
                                             when 'debian'
                                               '/etc/nginx'
                                           end
