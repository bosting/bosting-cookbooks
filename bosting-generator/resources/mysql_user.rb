resource_name :mysql_user

property :login, String, name_property: true
property :hashed_password, String

action_class do
  include BostingGenerator::Helper
end

action :create do
  mysql_database_user new_resource.login do
    sensitive true
    connection mysql_connection_info
    password hashed_password(new_resource.hashed_password)
    host '%'
    action :create
  end
end

action :destroy do
  mysql_database_user new_resource.login do
    connection mysql_connection_info
    action :drop
  end
end
