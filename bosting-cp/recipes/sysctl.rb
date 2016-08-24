include_recipe 'sysctl'

if node['platform'] == 'freebsd'
  sysctl_param('security.bsd.see_other_uids') { value 0 }
end
