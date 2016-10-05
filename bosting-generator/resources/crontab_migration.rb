resource_name :crontab_migration

property :user, String, name_property: true
property :source_jail, String, required: true
property :destination_jail, String, required: true

action :move do
  source = "/usr/jails/#{source_jail}/var/cron/tabs/#{user}"
  destination = "/usr/jails/#{destination_jail}/var/cron/tabs/#{user}"
  execute "mv #{source} #{destination}" do
    only_if { ::File.exists?(source) }
  end
end
