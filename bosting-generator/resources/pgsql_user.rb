resource_name :pgsql_user

property :login, String, name_property: true
property :hashed_password, String

action_class do
  include BostingGenerator::Helper
end

action :create do
  postgresql_database_user new_resource.login do
    sensitive true
    connection pgsql_connection_info
    password hashed_password(new_resource.hashed_password)
    action :create
  end
end

action :destroy do
  postgresql_database_user new_resource.login do
    connection pgsql_connection_info
    action :drop
  end
end
