resource_name :rails_command

property :name, name_property: true
property :command, String, required: true

action :run do
  bash new_resource.name do
    code <<-EOH
      source ~/.zshrc
      #{new_resource.command}
EOH
    cwd node['bosting-cp']['rails']['site_home']
    user node['bosting-cp']['rails']['user']
    group node['bosting-cp']['rails']['group']
    environment node['bosting-cp']['rails']['ruby_env_vars']
  end
end
