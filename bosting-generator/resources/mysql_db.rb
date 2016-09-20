resource_name :mysql_db

property :db_name, String, name_property: true
property :mysql_user, String, required: true

action_class do
  include BostingGenerator::Helper
end

action :create do
  mysql_database new_resource.db_name do
    connection mysql_connection_info
    action :create
  end

  mysql_database_user new_resource.mysql_user do
    connection mysql_connection_info
    database_name new_resource.db_name
    host '%'
    action :grant
  end
end

action :destroy do
  mysql_database_user new_resource.mysql_user do
    connection mysql_connection_info
    database_name new_resource.db_name
    host '%'
    action :revoke
  end

  mysql_database new_resource.db_name do
    connection mysql_connection_info
    action :drop
  end
end
