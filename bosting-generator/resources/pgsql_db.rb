resource_name :pgsql_db

property :db_name, String, name_property: true
property :pgsql_user, String, required: true

action_class do
  include BostingGenerator::Helper
end

action :create do
  postgresql_database new_resource.db_name do
    connection pgsql_connection_info
    owner new_resource.pgsql_user
    action :create
  end

  # postgresql_database_user new_resource.pgsql_user do
  #   connection pgsql_connection_info
  #   database_name new_resource.db_name
  #   action :grant
  # end
end

action :destroy do
  # postgresql_database_user new_resource.pgsql_user do
  #   connection pgsql_connection_info
  #   database_name new_resource.db_name
  #   action :revoke
  # end

  postgresql_database new_resource.db_name do
    connection pgsql_connection_info
    action :drop
  end
end
