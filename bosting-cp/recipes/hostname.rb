fqdn = node['bosting-cp']['fqdn']
case node['platform']
  when 'freebsd'
    replace_or_add 'hostname' do
      path '/etc/rc.conf'
      pattern 'hostname=.*'
      line "hostname=\"#{fqdn}\""
    end
  when 'debian'
    file '/etc/hostname' do
      content fqdn
    end
end

execute "hostname #{fqdn}"

if node['platform'] == 'freebsd'
  file '/etc/bosting_name' do
    content 'root'
    mode 0600
  end
end
