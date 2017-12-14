default['ruby_build']['git_ref'] = 'v20170914'
default['rbenv']['git_ref'] = 'v1.0.0'
default['rbenv']['rubies'] = ['2.4.2']
default['rbenv']['gems'] = { '2.4.2' => [{ 'name' => 'bundler' }] }
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

default['bosting-cp']['rails']['home'] = '/home/bosting'
default['bosting-cp']['rails']['site_home'] = default['bosting-cp']['rails']['home'] + '/bosting-cp'
default['bosting-cp']['rails']['user'] = 'bosting'
default['bosting-cp']['rails']['group'] = 'www'
default['bosting-cp']['rails']['ruby_env_vars'] = {
   'RAILS_ENV' => 'production',
   'PATH' => "/usr/local/rbenv/shims:#{ENV['PATH']}",
   'HOME' => default['bosting-cp']['rails']['home']
}
